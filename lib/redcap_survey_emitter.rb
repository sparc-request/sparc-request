require 'digest/sha1'

class RedcapSurveyEmitter

  def initialize(feedback)
    @feedback = feedback
  end

  def send_form
    record = {
      :letters => latest_letter_id + 1,
      :name => @feedback.name,
      :email => @feedback.email,
      :date => Date.strptime(@feedback.date[0..9], '%m/%d/%Y').strftime("%Y/%m/%d").gsub('/', '-'),
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

  private

  def latest_letter_id
    fields = {
      :token => REDCAP_TOKEN,
      :content => 'record',
      :format => 'json',
      :type => 'flat'
    }

    ch = Curl::Easy.http_post(
      REDCAP_API,
      fields.collect{|k, v| Curl::PostField.content(k.to_s, v)}
    )

    to_array = JSON.parse(ch.body_str)

    to_array.last['letters'].to_i
  end
end

