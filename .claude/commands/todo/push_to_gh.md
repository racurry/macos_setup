---
description: Analyze todos in docs/TODO.md, create GitHub issues for clear items, and add clarifying questions for unclear ones
---

# Push todos to Github

For every todo in the "Ready" section of docs/TODO.md:

1. Use a todo-analyzer agent to analyze the todo.  The agent will return a structured response indicating if the todo is clear or needs clarification.
   - If the todo is CLEAR, proceed to step 2.
   - If the todo NEEDS CLARIFICATION, proceed to step 3.

2. For todos that are CLEAR:
   - Use `gh issue create` to open an issue in the repository, using the detailed prompt returned by the todo-analyzer agent.
   - Update docs/TODO.md to mark the todo as completed with a link to the created GitHub issue.

3. For todos that NEED CLARIFICATION:
   - Update docs/TODO.md to add clarifying questions as sub-bullets under unclear todos

Launch all sub-agents in parallel for efficiency.
