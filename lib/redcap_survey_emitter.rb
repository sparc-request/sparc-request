require 'digest/sha1'

class RedcapSurveyEmitter

  def initialize(feedback)
    @feedback = feedback
  end

  def send_form
    record = {
      :letters => Digest::SHA1.hexdigest(Time.now.usec.to_s)[0..16],
      :name => @feedback.name,
      :email => @feedback.email,
      :date => @feedback.date.to_datetime.strftime("%Y/%m/%d").gsub('/', '-'),
      :typeofrequest => @feedback.typeofrequest,
      :priority => @feedback.priority,
      :browser => @feedback.browser,
      :version => @feedback.version,
      :sparc_request_id => @feedback.sparc_request_id
      }

    data = [record].to_json

    fields = {
      :token => REDCAP_TOKEN,
      :content => 'record',
      :format => 'json',
      :type => 'flat',
      :data => data,
    }

    ch = Curl::Easy.http_post(
      REDCAP_API,
      fields.collect{|k, v| Curl::PostField.content(k.to_s, v)}
    )

    ch.body_str
  end
end
