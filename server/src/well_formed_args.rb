require_relative 'base58'
require 'json'

# Checks for arguments synactic correctness

class WellFormedArgs

  def initialize(s)
    @args = JSON.parse(s)
  rescue
    raise ArgumentError.new('json:malformed')
  end

  # - - - - - - - - - - - - - - - -

  def manifest
    @arg_name = __method__.to_s

    unless arg.is_a?(Hash)
      malformed
    end
    unless all_required_keys?
      malformed
    end
    if any_unknown_key?
      malformed
    end

    arg.keys.each do |key|
      value = arg[key]
      case key
      when 'group'
        unless is_base58?(value)
          malformed
        end
      when 'display_name', 'image_name', 'runner_choice', 'exercise'
        unless value.is_a?(String)
          malformed
        end
      when 'highlight_filenames','progress_regexs','hidden_filenames'
        unless value.is_a?(Array)
          malformed
        end
        value.each { |val|
          unless val.is_a?(String)
            malformed
          end
        }
      when 'tab_size', 'max_seconds'
        unless value.is_a?(Integer)
          malformed
        end
      when 'created'
        unless is_time?(value)
          malformed
        end
      when 'filename_extension'
        value = [ value ] if value.is_a?(String)
        unless value.is_a?(Array)
          malformed
        end
        value.each { |val|
          unless val.is_a?(String)
            malformed
          end
        }
      end
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def files
    @arg_name = __method__.to_s
    unless arg.is_a?(Hash)
      malformed
    end
    arg.each { |filename,content|
      unless filename.is_a?(String)
        malformed
      end
      unless content.is_a?(String)
        malformed
      end
    }
    arg
  end

  # - - - - - - - - - - - - - - - -

  def id
    @arg_name = __method__.to_s
    unless is_base58?(arg)
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def n
    @arg_name = __method__.to_s
    unless arg.is_a?(Integer)
      malformed
    end
    unless arg >= -1
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def now
    @arg_name = __method__.to_s
    unless arg.is_a?(Array)
      malformed
    end
    unless arg.length == 6
      malformed
    end
    unless arg.all?{ |n| n.is_a?(Integer) }
      malformed
    end
    Time.mktime(*arg)
    arg
  rescue ArgumentError
    malformed
  end

  # - - - - - - - - - - - - - - - -

  def stdout
    @arg_name = __method__.to_s
    unless arg.is_a?(String)
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def stderr
    @arg_name = __method__.to_s
    unless arg.is_a?(String)
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def status
    @arg_name = __method__.to_s
    unless arg.is_a?(Integer)
      malformed
    end
    unless (0..255).include?(arg)
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def colour
    @arg_name = __method__.to_s
    unless ['red','amber','green','timed_out'].include?(arg)
      malformed
    end
    arg
  end

  private # = = = = = = = = = = = =

  attr_reader :args, :arg_name

  def arg
    args[arg_name]
  end

  # - - - - - - - - - - - - - - - -

  def all_required_keys?
    REQUIRED_KEYS.all? { |required_key| arg.keys.include?(required_key) }
  end

  REQUIRED_KEYS = %w(
    display_name
    image_name
    runner_choice
    created
  )

  # - - - - - - - - - - - - - - - -

  def any_unknown_key?
    arg.keys.any? { |key| !KNOWN_KEYS.include?(key) }
  end

  KNOWN_KEYS = REQUIRED_KEYS + %w(
    id
    group
    exercise
    filename_extension
    highlight_filenames
    hidden_filenames
    progress_regexs
    tab_size
    max_seconds
  )

  # - - - - - - - - - - - - - - - -

  def is_base58?(s)
    Base58.string?(s) && s.length == 6
  end

  # - - - - - - - - - - - - - - - -

  def is_time?(arg)
    return false unless arg.is_a?(Array)
    return false unless arg.size == 6
    return false unless arg.all? { |n| n.is_a?(Integer) }
    Time.mktime(*arg)
    true
  rescue
    false
  end

  # - - - - - - - - - - - - - - - -

  def malformed
    raise ArgumentError.new("#{arg_name}:malformed")
  end

end