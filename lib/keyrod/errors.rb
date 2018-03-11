module Keyrod
  module Errors
    class ResponseError < StandardError; end
    class ConnectionError < StandardError; end
    class ParamsError < StandardError; end
    class ProjectError < StandardError; end
  end
end
