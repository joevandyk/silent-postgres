if Rails.env.development? || Rails.env.test?

  require "silent-postgres/railtie"

  module SilentPostgres
    SILENCED_METHODS = [
      "tables",
      "table_exists?",
      "indexes",
      "client_min_messages",
      "standard_conforming_strings",
      "column_definitions",
      "pk_and_sequence_for",
      "last_insert_id",
      "PK and custom sequence",
      "SELECT a.attname"
    ]

    def self.included(base)
      SILENCED_METHODS.each do |m|
        base.send :alias_method_chain, m, :silencer
      end
    end

    SILENCED_METHODS.each do |m|
      m1, m2 = if m =~ /^(.*)\?$/
                 [$1, '?']
               else
                 [m, nil]
      end

      eval <<-METHOD
        def #{m1}_with_silencer#{m2}(*args)
          @logger.silence do
            #{m1}_without_silencer#{m2}(*args)
          end
        end
      METHOD
    end
  end

end

