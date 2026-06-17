# Operations Prompt

Given this task, approach, and structure:

Task: `5.0 In separate PR: Fix bug in which keyboard is not dismissable while editing Notes text input.`

Structure: `<paste structure>`

Decompose this into concrete, reviewable operations.

For each operation, include:

- Exact action
- Expected files or test targets
- Verification command or manual check
- Build ownership: user-run
- Manual validation notes to capture when the user builds or inspects locally
- Commit boundary and proposed commit title of 52 characters or fewer
- Whether the operation can be committed without breaking compilation
- Done condition

Required operation coverage:

- Locate every current Notes input used by the inspection step or stage flow.
- Add a dismissal affordance for the software keyboard.
- Preserve note text while dismissing the keyboard.
- Keep the broader Done/save action behavior unchanged.
- Update the OpenSpec task checkbox only after the fix is complete.

Do not build the code automatically. Specify the exact user-run build or inspection signal the user should report back.

When this task becomes a PR, use this title:

`TASK#5.0: Fix notes keyboard dismissal`
