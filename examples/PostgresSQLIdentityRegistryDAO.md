package useraccounts.boundary.outbound

import arrow.core.Either
import arrow.core.Option
import arrow.core.left
import arrow.core.right
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import sharedkernel.domain.AggregateResult
import useraccounts.domain.aggregates.identityregistry.IdentityRegistryId
import useraccounts.domain.aggregates.identityregistry.IdentityRegistryState
import useraccounts.domain.repositories.IdentityRegistryRepository
import useraccounts.domain.repositories.IdentityRegistryRepositoryError
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

// Exposed table definition
object IdentityRegistriesTable : Table("identity_registries") {
val id = varchar("id", 36)
val version = long("version")
val aggregateData = text("aggregate_data")
val createdAt = long("created_at")
val updatedAt = long("updated_at")

    override val primaryKey = PrimaryKey(id)
}

class PostgresSQLIdentityRegistryDAO(
private val database: Database
) : IdentityRegistryRepository {

    // JSON serialization helper
    private val json = Json { 
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    // Load WITH version (internal to DAO)
    private data class AggregateWithVersion(
        val aggregate: IdentityRegistryState,
        val version: Long
    )

    private suspend fun loadWithVersion(id: IdentityRegistryId): AggregateWithVersion? {
        return newSuspendedTransaction(db = database) {
            IdentityRegistriesTable
                .select { IdentityRegistriesTable.id eq id.value.toString() }
                .singleOrNull()
                ?.let { row ->
                    val jsonString = row[IdentityRegistriesTable.aggregateData]
                    val version = row[IdentityRegistriesTable.version]
                    val aggregate = json.decodeFromString<IdentityRegistryState>(jsonString)
                    AggregateWithVersion(aggregate, version)
                }
        }
    }

    override suspend fun saveState(aggregateResult: AggregateResult<IdentityRegistryState>): Either<IdentityRegistryRepositoryError, IdentityRegistryState> {
        return newSuspendedTransaction(db = database) {
            loadWithVersion(aggregateResult.newState.id)?.let { existingAggregate ->
                // UPDATE with optimistic concurrency control
                val rowsUpdated = IdentityRegistriesTable.update(
                    where = { 
                        (IdentityRegistriesTable.id eq aggregateResult.newState.id.value.toString()) and 
                        (IdentityRegistriesTable.version eq existingAggregate.version) 
                    }
                ) {
                    it[aggregateData] = json.encodeToString(aggregateResult.newState)
                    it[version] = existingAggregate.version + 1
                    it[updatedAt] = System.currentTimeMillis()
                }

                if (rowsUpdated == 0) {
                    IdentityRegistryRepositoryError.ConcurrencyConflict.left()
                } else {
                    aggregateResult.newState.right()
                }
            } ?: run {
                // INSERT - new aggregate
                IdentityRegistriesTable.insert {
                    it[id] = aggregateResult.newState.id.value.toString()
                    it[version] = 1L
                    it[aggregateData] = json.encodeToString(aggregateResult.newState)
                    it[createdAt] = System.currentTimeMillis()
                    it[updatedAt] = System.currentTimeMillis()
                }
                aggregateResult.newState.right()
            }
        }
    }

    override suspend fun loadState(id: IdentityRegistryId): IdentityRegistryState? {
        return newSuspendedTransaction(db = database) {
            loadWithVersion(id)?.aggregate
        }
    }

    override suspend fun loadStateAsOption(id: IdentityRegistryId): Option<IdentityRegistryState> {
        return Option.fromNullable(loadState(id))
    }
}