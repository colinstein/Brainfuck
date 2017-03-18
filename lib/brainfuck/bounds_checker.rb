module Brainfuck

  module BoundsChecker

    def check_bounds(*args)
      options = build_options(args)

      unless options[:options].fetch(:proc, nil).respond_to? :call
        raise ArgumentError.new("no proc: for check_bounds")
      end

      options[:methods].each do |method|
        self.prepend(build_proxy_module(method, options[:options][:proc]))
      end
    end

    private

    def build_options(args)
      args.inject({methods: [], options: {}}) do |memo, arg|
        memo.tap do |m|
          arg.class == Hash ? m[:options] = arg : m[:methods] << arg.to_sym
        end
      end
    end

    def build_proxy_module(method, block)
      Module.new do
        define_method(method) do |*args|
          index = args.fetch(0, nil)
          if index.nil? || !instance_exec(index, &block)
            raise ArgumentError.new("index out of bounds")
          end
          super(*args)
        end
      end
    end

  end

end
