# SOFTWARE PRINCIPLES

*Version: 2.0 | Last Updated: January 17, 2026 | Includes Clean Code Integration*

## Summary

- **Tell Don't Ask** - Tell objects what to do, don't query their state
- **Intention-Revealing Names and Functions** - Names and method signatures reveal true intent
- **Avoid Meaningless Suffixes** - No -Manager, -Handler, -Processor suffixes
- **Explicit over Implicit** - Clear intent over clever code
- **Make Errors Explicit and Illegal States Impossible** - Use type system + proper error handling
- **Objects Hide Data, Expose Behavior** - Objects vs data structures distinction
- **Interface Discovery Through Usage** - Design APIs from caller's perspective
- **The Boy Scout Rule** - Always leave code cleaner than you found it
- **One Thing Rule** - Each function/class does exactly one thing

---

## Detailed Principles

### **Tell** (so that others) **Don't** (need to) **Ask**
[Previous content remains the same]

### Intention-Revealing Names and Functions (Enhanced from Clean Code)
Both variable names and function names must clearly express their intent without requiring comments or investigation.

**For Names:**
```kotlin
// ❌ Mental mapping required
val d = 5  // What is d?
val users = getUsers()  // What kind of users? All? Active? 

// ✅ Intention-revealing names
val daysSinceCreation = 5
val activeUsers = getActiveUsers()
```

**For Functions (The "Intention Is" Test):**
A method name must pass this test: "The intention is [method name]." If this sentence doesn't make sense or prompts "Why?", the method name fails.
```kotlin
// ❌ Fails the test
fun getAccount(): Account 
// "The intention is getAccount" - Why? What for?

// ✅ Passes the test  
fun withdrawMoney(amount: Money): Either<InsufficientFunds, Account>
// "The intention is withdrawMoney" - Clear and complete!
```

**Clean Code Addition**: Use searchable names for anything that might be referenced multiple times. Single-letter variables only for loop counters in very short loops.

### The Boy Scout Rule
Always leave the code cleaner than you found it. This isn't about big refactoring - small improvements compound over time.
```kotlin
// When you touch this code...
fun calculateTotal(items: List<Item>): Double {
    var t = 0.0  // ❌ Poor name
    for (i in items) {
        t += i.price * i.qty  // ❌ Abbreviation
    }
    return t
}

// Leave it like this...
fun calculateTotal(items: List<Item>): Money {
    var total = Money.ZERO  // ✅ Clear name
    for (item in items) {
        total += item.price * item.quantity  // ✅ Full names
    }
    return total
}
```

**Examples of Boy Scout improvements:**
- Change one variable name for the better
- Break up one function that's too large
- Eliminate one small bit of duplication
- Clean up one composite if statement

### One Thing Rule
Each function should do one thing, do it well, and do it only. This applies to classes as well.
```kotlin
// ❌ Doing multiple things
fun processUser(userData: Map<String, String>): User {
    // 1. Validation
    if (userData["email"]?.contains("@") != true) {
        throw IllegalArgumentException("Invalid email")
    }
    
    // 2. Transformation
    val user = User(
        name = userData["name"] ?: "",
        email = userData["email"] ?: ""
    )
    
    // 3. Persistence
    database.save(user)
    
    // 4. Notification
    emailService.sendWelcome(user.email)
    
    return user
}

// ✅ Each function does one thing
fun validateUserData(userData: Map<String, String>): Either<ValidationError, ValidatedUserData>
fun createUser(validatedData: ValidatedUserData): User  
fun saveUser(user: User): Either<SaveError, SavedUser>
fun sendWelcomeEmail(user: User): Either<EmailError, Unit>
```

### Objects Hide Data, Expose Behavior (Enhanced from Both Sources)
This combines our "Getters/Setters are Evil" with Clean Code's objects vs data structures distinction.

**Objects** (hide data, expose behavior):
```kotlin
// ✅ Object - hides data structure, exposes behavior
class Account private constructor(private val balance: Money) {
    fun withdraw(amount: Money): Either<WithdrawalError, Account> {
        return when {
            balance < amount -> Either.Left(InsufficientFunds)
            else -> Either.Right(Account(balance - amount))
        }
    }
    
    // No getters! External code can't see balance directly
}
```

**Data Structures** (expose data, no behavior):
```kotlin
// ✅ Data structure - pure data holder, no behavior
data class UserDto(
    val name: String,
    val email: String,
    val createdAt: Instant
)
// Used for data transfer only, operated on by functions elsewhere
```

**Hybrid (avoid these)**:
```kotlin
// ❌ Hybrid - has both getters and behavior (violates both principles)
class BadAccount {
    var balance: Money = Money.ZERO  // Exposed data
        private set
    
    fun getBalance(): Money = balance  // Getter
    
    fun withdraw(amount: Money) {      // Behavior
        if (balance >= amount) {
            balance -= amount
        }
    }
}
```

### Make Errors Explicit and Illegal States Impossible (Enhanced)
Combines type safety with proper error handling from Clean Code.

**Type Safety (Make Illegal States Impossible):**
```kotlin
// ✅ Types prevent invalid construction
sealed class UserEmail {
    data class Unverified(val email: String) : UserEmail()
    data class Verified(val email: String) : UserEmail()
}
```

**Error Handling (Clean Code's "Prefer Exceptions to Return Codes"):**

From Clean Code, we classify errors into:
1. **Expected & Actionable** → Use Either/Result types
2. **Unexpected & System Failures** → Use exceptions
```kotlin
// ✅ Expected business errors - use Either
fun transfer(from: Account, to: Account, amount: Money): Either<TransferError, TransferReceipt>

// ✅ Unexpected system errors - use exceptions  
fun loadAccount(id: AccountId): Account {
    return try {
        database.load(id)
    } catch (e: IOException) {
        throw SystemException("Database unavailable", e)
    }
}
```

[Other existing principles remain the same...]

---

*Next files: 02-code-rules.md, 03-anti-patterns.md, 04-testing-patterns.md, 05-clean-code-formatting.md (NEW)*