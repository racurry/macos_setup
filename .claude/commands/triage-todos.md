---
description: Analyze todos in docs/TODO.md, create GitHub issues for clear items, and add clarifying questions for unclear ones
---

For every todo in the "Straightforward todos" section of docs/TODO.md:

1. Use a sub-agent for each todo item to analyze it. Each agent should:
   - Read the entire codebase to fully understand the context
   - Determine if the problem and solution are clear

2. For todos that are CLEAR:
   - Use `gh issue create` to open an issue in the repository
   - Include detailed problem description, solution approach, and specific implementation steps
   - Add enough detail so an AI agent can implement the solution

3. For todos that NEED CLARIFICATION:
   - Return a list of clarifying questions

4. Update docs/TODO.md:
   - Mark clear todos as completed with links to their GitHub issues
   - Add clarifying questions as sub-bullets under unclear todos

Launch all sub-agents in parallel for efficiency.
