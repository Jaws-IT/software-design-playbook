Version: 1.0.0

1. Explicitly state which Agent is running  
   Example:
   ```
   Running agent: BMAD-DEV
   ```
   Presentation rule:
   - Render this as a standalone banner line at the start of the response.
   - Use ANSI colors only when the output channel supports ANSI escapes (for example: real TTY terminal output).
   - If ANSI is supported, use white text on a blue background for the active agent banner: `\x1b[97;44m`.
   - Reset styling immediately after the banner with `\x1b[0m`.
   - If ANSI is not supported (for example: web/app/chat rendered output), always fall back to an uppercase bracketed line:
   ```
   [RUNNING AGENT: BMAD-DEV]
   ```
   - Never print raw escape sequences in non-ANSI channels.
   - Do not bury the agent line inside a paragraph, bullet explanation, or code block when presenting it in a real response.

2. Strictly follow that Agent’s Developer Doctrine.

3. Keep responses concise unless explicitly asked for expansion.

4. If Agent mode exits automatically, explicitly state:
   ```
   Agent mode exited: <AgentName>
   ```
   Presentation rule:
   - Apply the same standalone banner treatment and ANSI/fallback formatting as the active-agent line.
   - If ANSI is supported, use black text on a yellow background for the exit banner: `\x1b[30;43m`.
   - If ANSI is not supported, use uppercase bracketed fallback:
   ```
   [AGENT MODE EXITED: <AgentName>]
   ```
   - Never print raw escape sequences in non-ANSI channels.

This rule applies to all operation modes below.

5. Do not invent domain behavior, operations, commands, events, methods, or workflows that were not explicitly requested, documented in the loaded project context, or already present in the modeled ubiquitous language.
   - If a missing behavior seems necessary, stop and ask a clarifying question instead of filling the gap with a plausible-sounding design.
   - Prefer omission over invention when the source material is incomplete.
   - Treat guessed method names, guessed state transitions, and guessed domain events as defects, not helpful creativity.

6. When generating code or designs, every public domain behavior must be traceable to at least one of:
   - the user's explicit request
   - the project's ubiquitous language
   - the architecture or process documentation loaded for the task
   - already-existing code the task is extending
   If traceability is missing, do not generate the behavior yet.
