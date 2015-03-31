# http://homeonrails.com/2012/10/associationcountvalidator/

class MultipleEmailAddressesValidator < ActiveModel::EachValidator
  def validate(record)
    attributes.each do |attribute|
      emails = record.send(attribute).split(',')
      emails.each do |email|
        record.errors.add(attribute, I18n.translate(:invalid_multiple_email, :email => email)) unless email.strip =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      end
    end
  end
end
