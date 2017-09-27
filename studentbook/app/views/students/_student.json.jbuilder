json.extract! student, :id, :name, :phone, :town, :course, :paid_tuition, :created_at, :updated_at
json.url student_url(student, format: :json)
