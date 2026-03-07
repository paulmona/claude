# pm-prd-ready

Mark a Notion PRD as GitHub Ready.

## Usage
/pm-prd-ready $ARGUMENTS

Arguments: PRD ID or name (e.g. PRD-002, "Operational Assessment Tool")
If no argument provided, search Notion for Approved PRDs not yet marked GitHub Ready and ask which one.

## Steps

1. If $ARGUMENTS provided, use notion-search to find the matching PRD in the PRDs database.
   The database ID is in `~/.claude/notion-config.json` (key: `prd_database_id`). If the file doesn't exist or the key is missing, ask the user for their Notion PRD database ID and create/update the file.

2. If no argument, search for PRDs where Status = Approved and GitHub Ready = false.
   Present the list and ask the user which one to mark ready.

3. Confirm with the user before updating:
   "Ready to mark [PRD name] as GitHub Ready. This signals it's ready for /pm-bootstrap. Confirm?"

4. Use notion-update-page to set GitHub Ready = true on the PRD page.

5. Confirm: "PRD-[N] is marked GitHub Ready. Run /pm-bootstrap PRD-[N] paulmona/repo-name to kick off the project."
