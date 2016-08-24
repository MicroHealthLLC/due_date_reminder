# Due Date Reminder plugin for Redmine

Plugin for Redmine project that sends notification to assignee if due date is coming.

Users can choose on which days before due date they want to be notified.
This setting is located at the user account page.

![User settings](https://github.com/f0y/due_date_reminder/raw/redmine-2.x/doc/user_settings.png)

Moreover, administrator can set default notification settings for new users.

![Default settings](https://github.com/f0y/due_date_reminder/raw/redmine-2.x/doc/default_settings.png)

Plugin also sends info about issues behind a schedule.
Users cannot change this behavior.


## Installation

    cd /home/user/path_to_you_app/
    git clone https://github.com/btrd/due_date_reminder/ plugins/due_date_reminder

### Migrations

    bundle exec rake redmine:plugins:migrate RAILS_ENV=production

## Sending notifications
You can send notifications manually:

    cd /home/user/path_to_you_app
    bundle exec rake redmine:reminder_plugin:send_notifications RAILS_ENV=production

It is good idea to add the task to cron:

    crontab -e
    0 5 * * * cd /home/user/path_to_you_app && bundle exec rake redmine:reminder_plugin:send_notifications RAILS_ENV=production &> /tmp/redmine_due_date_reminder.log

You should run this task *only* *once* *a* *day*.

## License

This plugin is licensed under the GPLv2 license.
