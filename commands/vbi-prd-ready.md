# vbi-prd-ready

Mark a Viewbridge Notion PRD as GitHub Ready.

## Usage
/vbi-prd-ready $ARGUMENTS

Arguments: PRD ID or name (e.g. PRD-002, "Operational Assessment Tool")
If no argument provided, search Notion for Approved PRDs not yet marked GitHub Ready and ask which one.

## Steps

1. If $ARGUMENTS provided, use notion-search to find the matching PRD in the Viewbridge PRDs database:
   https://www.notion.so/2aaef788dde1436ab285c62124211c4f

2. If no argument, search for PRDs where Status = Approved and GitHub Ready = false.
   Present the list and ask the user which one to mark ready.

3. Confirm with the user before updating:
   "Ready to mark [PRD name] as GitHub Ready. This signals it's ready for /vbi-bootstrap. Confirm?"

4. Use notion-update-page to set GitHub Ready = true on the PRD page.

5. Confirm: "PRD-[N] is marked GitHub Ready. Run /vbi-bootstrap PRD-[N] paulmona/repo-name to kick off the project."
