# Here's a framework to separate the model from the serializer.
#
# Let's say we want to serialize a nontrivial data structure which holds
# ActiveRecord models, e.g.:
#
#   class Identity < ActiveRecord::Base
#     ...
#   end
#
#   identities = Identity.all
#
# Here we have an array of Identity instances.  How do we serialize it
# to Json?
#
# ActiveRecord provides a serializer for us:
#
#   json = identities.to_json
#
# but what if the json doesn't look like the json we want to produce?
# ActiveRecord lets us customize the way the json is produced:
#
#   class Identity
#     def as_json(options = nil)
#       ...
#     end
#   end
#
# but this means that the model knows about its view.  We could separate
# the two:
#
#   class IdentityView
#     def as_json(identity)
#       ...
#     end
#   end
#
# but this means that we can't reuse the framework that ActiveRecord
# provides; we can no longer trivially serialize an array of Identity
# objects without first converting to an array of IdentityView objects.
# For a more complex structure, this becomes even more unwieldy.
#
# The JsonSerializable module provides a framework which lets us reuse
# ActiveRecord's json serialization routines, but still lets us separate
# the view from the model, e.g.:
#
#   class Identity
#     include JsonSerializable
#     json_serializer :obisentity, IdentityView
#   end
#
# We can invoke this custom serializer with:
#
#   json = identities.to_json(:jsontype => :obisentity)
#
# There are also some additional methods that can also be invoked:
#
#   identities.update_from_json(json, :jsontype => :obisentity)
#   obj = Identities.create_from_json(json, :jsontype => :obisentity)
#   relationship = obj.create_from_json(json, :jsontype => :relationships)
#
module JsonSerializable
  # Override the default ActiveRecord as_json method.  If the :jsontype
  # option is provided, use it to find a registered serializer,
  # otherwise fall back on the default as_json.
  def as_json(options = nil)
    options ||= { }
    type = options[:jsontype]

    if type then
      serializer = self.class.find_json_serializer(type)
      return serializer.as_json(self, options)
    else
      return super(options)
    end
  end

  # Given a hash as returned from as_json (or as parsed by JSON.parse),
  # update the model's attributes and its children's attributes from the
  # hash.
  def update_from_json(hash, options = nil)
    options ||= { }
    type = options[:jsontype]

    if type then
      serializer = self.class.find_json_serializer(type)
      return serializer.update_from_json(self, hash, options)
    else
      return super(options)
    end
  end

  # This mixin is used to provide the create_from_json method as a class
  # method to the class mixing in this module.  Defining the method as a
  # class method would not result in the method being accessible as a
  # class method in the derived class.
  # TODO: is there a better way to do this?
  module SerializerConstructor
    # Given a hash as returned from as_json (or as parsed by JSON.parse),
    # create a new model from the attributes found in the hash.  This
    # variant is used for obisentity and obissimple (i.e.,
    # create_from_json is called in order to create a new object).
    def create_from_json(hash, options = nil)
      options ||= { }
      type = options[:jsontype]

      if type then
        serializer = self.find_json_serializer(type)
        return serializer.class.create_from_json(self, hash, options)
      else
        return super(options)
      end
    end
  end

  # Given a hash as returned from as_json (or as parsed by JSON.parse),
  # create a new model from the attributes found in the hash.  This
  # variant is used for relationships (i.e., create_from_json is called
  # on an object that has already been created).
  def create_from_json(hash, options = nil)
    options ||= { }
    type = options[:jsontype]

    if type then
      serializer = self.class.find_json_serializer(type)
      return serializer.create_from_json(self, hash, options)
    else
      return super(options)
    end
  end

  # Destroy the object using the parameters found in `hash`.
  def destroy_using_json(hash, options = nil)
    options ||= { }
    type = options[:jsontype]

    if type then
      serializer = self.class.find_json_serializer(type)
      return serializer.destroy_using_json(self, hash, options)
    else
      return super(options)
    end
  end

  # The Registrar module is used for registration of serializer classes
  # and for locating serializer classes at runtime.  The methods in the
  # Registrar class are called by the above methods and should not
  # normally be called by the user of the JsonSerializable module.
  module Registrar
    def self.extended(klass)
      # Add the json_serializers accessor to the class
      class << klass
        attr_reader :json_serializers
      end
    end

    # Define a new serializer with the given name.
    #
    # +type+        a Symbol denoting the serializer type
    # +serializer+  the serializer Class
    #
    def json_serializer(type, serializer)
      @json_serializers ||= { }
      @json_serializers[type] = serializer.new
    end

    # Given a serializer type, return the associated serializer class.
    #
    # +type+        a Symbol denoting the serializer type
    #
    def find_json_serializer(type)
      serializers = self.json_serializers
      if not serializers then
        raise ArgumentError, "No serializers found for #{self.class.name}.  This can happen if you included the JsonSerializable module in a class but did not define any serializers, or if you included the JsonSerializable module in a base class but did not define serializers for the derived class."
      end

      serializer = serializers[type]
      if not serializer then
        raise ArgumentError, "No serializer #{type.inspect} found for #{self.class.name}"
      end

      return serializer
    end
  end

  def self.included(klass)
    # Add the json_serializer method to the class
    klass.extend(Registrar)

    # Add the create_from_json method to the class
    klass.extend(SerializerConstructor)
  end
end

