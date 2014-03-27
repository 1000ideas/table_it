# Redmine Table It plugin

## Instalation
1. Add plugin to your redmine's plugins directory
2. Run `rails g table_it`
3. Restart application

## Configuration

1. Configure roles and permissions. Plugin adds four new permissions:
  * Time actions - start time registration, stop time registration or add time to issues;
  * Poke - poke assignee by sending email;
  * Close/reopen issue - close issue by selecting checkbox on list, reopen by unselecting it;
  * List project users - get users allowed to be assigned to project.
2. Configure plugin at `/settings/plugin/table_it`:
  * Setup default users for projects. When you change project in new issue form, user will be selected by default;
  * Setup default activity for each role. It will be used with time actions: stop issue time and add time entry to issue;
  * Select custom field which contain issues's end time.
  * Select default statuses for closing/reopeing issue using checkbox.
3. Enable plugin for each project you want to see on homepage. You can enable it by default. Select `table it` plugin in modules list at `/settings?tab=projects`. You can also enable it for all existing projects calling `rake table_it:enable`.

## Additional info

You can use route `/stop_progress_times` for stopping all started time registrations of issues assigned to current user (by token).
