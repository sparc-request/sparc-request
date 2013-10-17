class AddAppointmentCompletionsForPftCore < ActiveRecord::Migration
  def change
    Appointment.all.each do |app|
      app.create_appointment_completions
    end
  end
end
