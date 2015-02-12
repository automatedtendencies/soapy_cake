module SoapyCake
  class Request
    attr_accessor :api_key, :time_offset
    attr_reader :role, :service, :method, :opts

    def initialize(role, service, method, opts = {})
      @role = role.to_s
      @service = service.to_s
      @method = method.to_s
      @opts = opts
    end

    def path
      "/#{(role != 'admin') ? role : ''}/api/#{version}/#{service}.asmx"
    end

    def xml
      Nokogiri::XML::Builder.new do |xml|
        xml['env'].Envelope(xml_namespaces) do
          xml.Header
          xml.Body do
            xml['cake'].send(method.camelize.to_sym) do
              xml_params(xml)
            end
          end
        end
      end.to_xml
    end

    private

    def xml_params(xml)
      xml.api_key api_key
      opts.each do |k, v|
        xml.send(k.to_sym, format_param(v))
      end
    end

    def xml_namespaces
      {
        'xmlns:env' => 'http://www.w3.org/2003/05/soap-envelope',
        'xmlns:cake' => "http://cakemarketing.com/api/#{version}/"
      }
    end

    def format_param(value)
      case value
      when Time, DateTime, Date
        (value.to_datetime.utc + time_offset.to_i.hours).strftime('%Y-%m-%dT%H:%M:%S')
      else
        value
      end
    end

    def version
      API_VERSIONS[role][service][method] || fail
    rescue
      raise(Error, "Unknown API call #{role}::#{service}::#{method}")
    end
  end
end