require_relative 'singler_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 400, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  private

  def inner_call
    html = [
      pre('kata_create') {
        @id = singler.kata_create(starter.manifest)
      },
      pre('kata_manifest') {
        singler.kata_manifest(@id)
      },
      pre('kata_ran_tests') {
        singler.kata_ran_tests(@id, 1, edited_files, now, stdout, stderr, status, colour)
      },
      pre('kata_tags') {
        singler.kata_tags(@id)
      },
      pre('kata_tag') {
        singler.kata_tag(@id, 1)
      }
    ].join
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  # - - - - - - - - - - - - - - - - -

  def edited_files
    files = starter.manifest['visible_files']
    edited = files['hiker.c']
    files['hiker.c'] = edited.sub('6 * 9', '6 * 7')
    files
  end

  def now
    [2016,12,2, 6,14,37]
  end

  def stdout
    'All tests passed'
  end

  def stderr
    ''
  end

  def status
    0
  end

  def colour
    'green'
  end

  # - - - - - - - - - - - - - - - - -

  def pre(name, &block)
    result,duration = *timed { block.call }
    [
      "<pre>/#{name}(#{duration}s)</pre>",
      "<pre style='#{style}'>",
        "#{JSON.pretty_unparse(result)}",
      '</pre>'
    ].join
  end

  def style
    [whitespace,margin,border,padding,background].join
  end

  def border
    'border: 1px solid black;'
  end

  def padding
    'padding: 10px;'
  end

  def margin
    'margin-left: 30px; margin-right: 30px;'
  end

  def background
    'background: white;'
  end

  def whitespace
    'white-space: pre-wrap;'
  end

  # - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    [result,duration]
  end

  # - - - - - - - - - - - - - - - - -

  def singler
    SinglerService.new
  end

  def starter
    StarterService.new
  end

end


