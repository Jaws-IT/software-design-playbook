1. Explicitly state which Agent is running  
   Example:
   ```
   Running agent: BMAD-DEV
   ```
   Presentation rule:
   - Render this as a standalone banner line at the start of the response.
   - If terminal styling is supported, use explicit ANSI colors so the banner renders consistently across sessions.
   - Use white text on a blue background for the active agent banner: `\x1b[97;44m`.
   - Reset styling immediately after the banner with `\x1b[0m`.
   - If ANSI styling is not supported, fall back to an uppercase bracketed line:
   ```
   [RUNNING AGENT: BMAD-DEV]
   ```
   - Do not bury the agent line inside a paragraph, bullet explanation, or code block when presenting it in a real response.

2. Strictly follow that Agent’s Developer Doctrine.

3. Keep responses concise unless explicitly asked for expansion.

4. If Agent mode exits automatically, explicitly state:
   ```
   Agent mode exited: <AgentName>
   ```
   Presentation rule:
   - Apply the same standalone banner treatment and ANSI/fallback formatting as the active-agent line.
   - Use black text on a yellow background for the exit banner: `\x1b[30;43m`.

This rule applies to all operation modes below.
