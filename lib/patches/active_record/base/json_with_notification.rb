module ActiveRecord

  class Base

    def json_with_notification(action, args = {})
      resource = self.class.to_s.downcase.underscore
      notification_type = args[:type] || :notice
      { :notification => { :text => I18n.t("notifications.#{resource.pluralize}.#{action}"), :type => notification_type },
        resource.to_sym => self
      }
    end

  end


end
