class ReminderMailer < Mailer
  include Redmine::I18n

  prepend_view_path "#{Redmine::Plugin.find("due_date_reminder").directory}/app/views"

  def self.due_date_notifications
    data = {}
    issues = self.find_issues
    issues.each { |issue| self.insert(data, issue) }
    data.each do |user, projects|
      due_date_notification(user, projects).deliver
    end
  end

  def due_date_notification(user, projects)
    set_language_if_valid user.language
    @projects = projects
    @issues_url = url_for(:controller => 'issues', :action => 'index',
                          :set_filter => 1, :assigned_to_id => user.id,
                          :sort => 'due_date:asc')
    mail :to => user.mail, :subject => l(:reminder_mail_subject)
  end


  def self.find_issues
    if Redmine::VERSION::MAJOR >= 3
      scope = Issue.where(
        "(#{Issue.table_name}.assigned_to_id IS NOT NULL)" +
        " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
        " AND #{Issue.table_name}.due_date IS NOT NULL" +
        " AND #{User.table_name}.status = #{User::STATUS_ACTIVE}"
      )
      issues = scope.joins(:status, :assigned_to, :project, :tracker).to_a
      issues.reject! { |issue| not (issue.remind? or issue.overdue?) }
      issues.sort! { |first, second| first.due_date <=> second.due_date }
    else
      scope = Issue.open.scoped(:conditions => [
        "(#{Issue.table_name}.assigned_to_id IS NOT NULL)" +
        " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
        " AND #{Issue.table_name}.due_date IS NOT NULL" +
        " AND #{User.table_name}.status = #{User::STATUS_ACTIVE}"
      ])
      issues = scope.all(:include => [:status, :assigned_to, :project, :tracker])
      issues.reject! { |issue| not (issue.remind? or issue.overdue?) }
      issues.sort! { |first, second| first.due_date <=> second.due_date }
    end
  end

  private

  def self.insert(data, issue)
    return unless check_custom_value(issue)
    data[issue.assigned_to] ||= {}
    data[issue.assigned_to][issue.project] ||= []
    data[issue.assigned_to][issue.project] << issue
  end

  def self.check_custom_value(issue)
    return CustomValue.find_or_initialize_by(custom_field_id: id_custom_field, customized_id: issue.id).value == "1"
  end

  def self.id_custom_field
    @id_custom_field ||= CustomField.find_by(name: "Rappel par mail").id
  end
end
