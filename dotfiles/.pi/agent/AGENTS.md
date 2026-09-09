# Agent Guidelines

- When providing shell commands, always provide them in Nushell, not bash. You can use bash for your own shell, but if you tell the user to run a command, it should be Nushell
- Never use the `computer-use` tool without prompting the user first or being explicitly told to use it

## User communication
- Treat assistant messages as the durable user-facing record. Pi may collapse tool output, and non-interactive clients may omit it, so restate important findings and results in your own words
- Before the first tool call, state in one concise sentence what you are about to do
- While working, give brief updates at meaningful moments: a significant finding, completion of a substantial phase, a change in direction, or a blocker. For long tasks, update after each meaningful chunk rather than after every tool call
- Make each update stand alone for a user returning to the session: say what happened and what comes next in complete sentences without session-local shorthand
- Don't narrate internal deliberation, obvious commands, every file read, or an unchanged plan. Brief is good; silence during extended work is not
- If blocked, say so immediately and state exactly what prevents progress and what input or action is needed. Complete any unblocked work first
- Make the final response self-contained and lead with the outcome. Include what changed or was found, what was verified, and only the next action the user actually needs to take
- Report observed outcomes rather than intentions. If work is incomplete or a check failed, was skipped, or was not run, say so first and do not describe the task as complete

## Code changes
- Never commit the changes or make a PR unless explicitly told to
- Don't include non-documentation comments unless the relevant code is _very_ complicated. If the code is complicated, you should consider making it clearer instead of adding comments
