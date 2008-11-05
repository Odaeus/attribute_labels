ActiveRecord::Base.send(:include, AttributeLabels::ActiveRecordLabels)
ActionView::Helpers::FormBuilder.send(:include, AttributeLabels::ActionViewLabels::FormBuilderLabels)
