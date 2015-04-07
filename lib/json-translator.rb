require 'json'

class JT
  def translate(data, &block)
    raise 'JT#translate no block given' unless block_given?

    data = JSON.parse(data) if data.is_a? String

    raise 'JT#translate expects hash or array' unless [Hash, Array].include? data.class

    @data = data
    @data_pointer = @data

    @result = @data.class.new
    @result_pointer = @result

    instance_eval &block

    @result
  end

  def method_missing(name, *args, &block)
    raise "JT##{name} expects 0 or 1 argument" if args.size > 1
    raise "JT##{name} can't get key from #{@data_pointer.inspect}" unless @data_pointer.is_a? Hash
    raise "JT##{name} can't set key to #{@result_pointer.inspect}" unless @result_pointer.is_a? Hash

    value = (args.first || name).to_s
    value = block.call(value) if block_given?

    @result_pointer[name] = @data_pointer[value]
  end

  def scope(name, &block)
    raise 'JT#scope no block given' unless block_given?
    raise 'JT#scope expects symbol or string' unless [Symbol, String].include? name.class
    raise 'JT#scope could not be called on array' unless @data_pointer.is_a? Hash

    tmp = @data_pointer

    case name
    when Symbol
      @data_pointer = @data_pointer[name.to_s]
    when String
      name.split('.').each { |n| @data_pointer = @data_pointer[n] }
    end

    instance_eval &block
    @data_pointer = tmp
  end

  def namespace(name, &block)
    raise 'JT#namespace no block given' unless block_given?
    raise 'JT#namespace expects symbol or string' unless [Symbol, String].include? name.class
    raise 'JT#namespace could not be called on array' unless @result_pointer.is_a? Hash

    tmp = @result_pointer

    case name
    when Symbol
      @result_pointer[name] ||= {}
      @result_pointer = @result_pointer[name]
    when String
      name.split('.').each do |n|
        @result_pointer[n] ||= {}
        @result_pointer = @result_pointer[n]
      end
    end

    instance_eval &block
    @result_pointer = tmp
  end

  def iterate(*args, &block)
    raise 'JT#iterate no block given' unless block_given?
    raise 'JT#iterate expects 0 or 2 arguments' unless [0, 2].include? args.size

    if args.empty?
      @result_pointer.concat @data_pointer.map { |e| JT.new.translate(e, &block) }
    else
      raise 'JT#iterate expects symbols or strings' unless args.all? { |a| [Symbol, String].include? a.class }

      @result_pointer[args.first] = @data_pointer[args.last.to_s].map { |e| JT.new.translate(e, &block) }
    end
  end

  alias n namespace
  alias s scope
  alias i iterate

  def self.t(data, &block)
    JT.new.translate(data, &block)
  end
end

