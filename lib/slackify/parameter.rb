# frozen_string_literal: true

module Slackify
  # Base parameter class that any user defined parameters must inherit from
  class Parameter
    @@supported_parameters = []

    class << self
      # Any class inheriting from Slackify::Parameter will be added to
      # the list of supported parameters
      def inherited(subclass)
        @@supported_parameters.push(subclass.to_s)
      end

      # Show a list of the parameters supported by the app. Since we do
      # metaprogramming, we want to ensure we can only call defined parameter
      def supported_parameters
        @@supported_parameters
      end
    end
  end
end
