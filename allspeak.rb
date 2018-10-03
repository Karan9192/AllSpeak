require 'sinatra'#dependencies
require "sinatra/reloader" if development?
require 'twilio-ruby'
require "google/cloud/translate"
require 'json'

#project_id = "slatebot-217401"

# this allows us to use session variables
# see below

configure :development do
  require 'dotenv'
  Dotenv.load
end

enable :sessions # configuration
secret_code = "MySecretCode"

Google::Cloud::Translate.configure do |config|
  config.project_id  = "slatebot-217401"
  config.credentials = "Slatebot-c5ec3f054ee6.json"
end

#$translate = Google::Cloud::Translate.new
#project: "Slatebot-c5ec3f054ee6.json"

def transl8 (input,lang)     #method to translate incoming text
    translate = Google::Cloud::Translate.new
    detection = translate.detect input.to_s
    #puts input + "Looks like you're speak in #{detection.language}"
    #puts "Confidence: #{detection.confidence}"
    #translation = translate.translate "Hello world!", to: "la"
    translation = translate.translate input.to_s, to: lang.to_s
    return "In #{lang} that's " + translation
end

def listlang #method to show language code
    language_code = "en"
    languages = $translate.languages
    puts "Supported languages:"
    languages.each do |language|
            puts "#{language.code} #{language.name}"
    end
end

#Translate End-point https://translation.googleapis.com/language/translate/v2 endpoint

get "/sms/incoming" do
  session["counter"] ||= 1
  incoming_text = params[:Body] || ""
  sender = params[:From] || ""
  if session["counter"]==1
    message="Hey! I'm AllSpeak, a translator bot. The list of supported languages are below. Just ask by typing (TEXT) (space) (Language Code)"
  else
    text_to_translate = incoming_text.split(' ')[0]
    lang_requested = incoming_text.split(' ')[1]
    message = transl8(text_to_translate, lang_requested)
  end

  #Look into Including method to set default language for commonly used phrases
  #puts twiml_body


# Build a twilio response object
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|
      # add the text of the response
      m.body(message)
      end
    end

 # send a response to twilio
  session["counter"] += 1
  content_type 'text/xml'
  twiml.to_s
end
