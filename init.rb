ActiveRecord::Base.send(:include, AttributeLabels::ActiveRecordLabels)
ActionView::Helpers::InstanceTag.send(:include, AttributeLabels::ActionViewLabels::InstanceTagLabels)
