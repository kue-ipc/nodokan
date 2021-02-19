# バイナリのデータが有るとエラーになる不具合の修正

module RailsAdmin
  module Extensions
    module PaperTrail
      class VersionProxy
        alias message_org message
        def message
          @message = @version.event
          if @version.respond_to?(:changeset) && @version.changeset.present?
            @message + ' [' + @version.changeset.to_a.collect do |c|
              value = c[1][1].to_s
              if value.encoding == Encoding::ASCII_8BIT
                value = value.unpack('H*').first
              end
              c[0] + ' = ' + value
            end.join(', ') + ']'
          else
            @message
          end
        end
      end
    end
  end
end
