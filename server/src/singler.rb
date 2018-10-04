require 'json'

# If all ids came from a single server I could use
# 6-character ids as the directory names and guarantee
# uniqueness at id generation.
# However, it is not uncommon to copy practice-sessions
# from one server to another, and uniqueness cannot be
# guaranteed in this case.
# Hence a 'visible' id is 6-characters and is
# completed to a 'private' 10-character id.
# When entering an id you will almost always only need
# 6-characters, but very very occasionally you may need
# to enter a 7th,8th.
# Using a base58 alphabet (but excluding L)
#   ==> 3^10 unique  6-character ids.
#   ==> 3^16 unique 10-character ids.

class Singler

  def initialize(externals)
    @externals = externals
    @path = '/singler/ids'
  end

  attr_reader :path

  def sha
    IO.read('/app/sha.txt').strip
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest, files)
    id = id_generator.generate
    manifest['id'] = id
    dir = id_dir(id)
    dir.make
    dir.write(manifest_filename, json_unparse(manifest))
    tag0 = {
         'event' => 'created',
          'time' => manifest['created'],
        'number' => 0
      }
    write_tags(id, [tag0])
    write_tag(id, 0, files, '', '', 0)
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    assert_id_exists(id)
    json_parse(id_dir(id).read(manifest_filename))
  end

  # - - - - - - - - - - - - - - - - - - -

  def id?(id)
    id_dir(id).exists?
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completed(partial_id)
    outer_id = outer(partial_id)
    inner_id = inner(partial_id)
    outer_dir = disk[dir_join(path, outer_id)]
    unless outer_dir.exists?
      return ''
    end
    # Slower with more inner dirs.
    dirs = outer_dir.each_dir.select { |inner_dir|
      inner_dir.start_with?(inner_id)
    }
    unless dirs.length == 1
      return ''
    end
    outer_id + dirs[0] # success!
  end

  # - - - - - - - - - - - - - - - - - - -

  def id_completions(outer_id)
    # for Batch-Method iteration over large number of practice-sessions...
    outer_dir = disk[dir_join(path, outer_id)]
    unless outer_dir.exists?
      return []
    end
    outer_dir.each_dir.collect { |inner_dir|
      outer_id + inner_dir
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, status, colour)
    assert_id_exists(id)
    tags = read_tags(id)
    next_tag = most_recent_tag(id, tags) + 1
    tags << { 'colour' => colour, 'time' => now, 'number' => next_tag }
    write_tags(id, tags)
    files['output'] = stdout + stderr # ???
    write_tag(id, next_tag, files, stdout, stderr, status)
    tags
  end

  # - - - - - - - - - - - - - - - - - - -

  def tags(id)
    assert_id_exists(id)
    read_tags(id)
  end

  def tag(id, n)
    if n == -1
      assert_id_exists(id)
      n = most_recent_tag(id)
    else
      assert_tag_exists(id, n)
    end
    read_tag(id, n)
  end

  private

  def manifest_filename
    'manifest.json'
  end

  def tags_filename
    'tags.json'
  end

  def tag_filename
    'tag.json'
  end

  # - - - - - - - - - - - - - -

  def write_tags(id, tags)
    dir = id_dir(id)
    dir.write(tags_filename, json_unparse(tags))
  end

  def read_tags(id)
    dir = id_dir(id)
    json_parse(dir.read(tags_filename))
  end

  # - - - - - - - - - - - - - -

  def write_tag(id, tag, files, stdout, stderr, status)
    dir = tag_dir(id, tag)
    dir.make
    json = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    dir.write(tag_filename, json_unparse(json))
  end

  def read_tag(id, tag)
    dir = tag_dir(id, tag)
    json_parse(dir.read(tag_filename))
  end

  def most_recent_tag(id, tags = nil)
    tags ||= read_tags(id)
    tags[-1]['number']
  end

  # - - - - - - - - - - - - - -

  def assert_id_exists(id)
    unless id_dir(id).exists?
      invalid('id', id)
    end
  end

  def id_dir(id)
    disk[id_path(id)]
  end

  def id_path(id)
    dir_join(path, outer(id), inner(id))
  end

  def outer(id)
    id[0..1]  # 2-chars long. eg 'e5'
  end

  def inner(id)
    id[2..-1] # 8-chars long. eg '6aM327PE'
  end

  # - - - - - - - - - - - - - -

  def assert_tag_exists(id, n)
    unless tag_dir(id, n).exists?
      invalid('tag', n)
    end
  end

  def tag_dir(id, tag)
    disk[tag_path(id, tag)]
  end

  def tag_path(id, tag)
    dir_join(id_path(id), tag.to_s)
  end

  # - - - - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  # - - - - - - - - - - - - - -

  def json_unparse(o)
    JSON.pretty_generate(o)
  end

  def json_parse(s)
    JSON.parse(s)
  end

  # - - - - - - - - - - - - - -

  def disk
    @externals.disk
  end

  def id_generator
    @externals.id_generator
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    fail ArgumentError.new("#{name}:invalid:#{value}")
  end

end
