require_relative 'test_base'

class SinglerTest < TestBase

  def self.hex_prefix
    '974'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190', %w( sha of image's git commit ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_exists?(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '392',
  'kata_exists? is false before creation, true after creation' do
    id = '50C8C6'
    refute kata_exists?(id)
    stub_kata_create(id)
    assert kata_exists?(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_create(), kata_manifest()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '421',
  'kata_create() generates an id if one is not supplied' do
    manifest = starter.manifest
    refute manifest.key?('id')
    id = kata_create(manifest)
    assert manifest.key?('id')
    assert_equal id, manifest['id']
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '424',
  'kata_create() ignores a generated id
  when a kata with that id already exists' do
    real_disk = ExternalDiskWriter.new
    stub_disk = StubDiskDirWriter.new(real_disk)
    singler = Singler.new(stub_disk)
    manifest = starter.manifest
    singler.kata_create(manifest)
    assert_equal 3, stub_disk.count
  end

  class StubDiskDirWriter
    def initialize(disk)
      @disk = disk
      @count = 0
    end
    attr_reader :count
    def [](name)
      @name = name
      self
    end
    def exists?
      @count += 1
      if @count < 3
        true
      else
        @disk[@name].exists?
      end
    end
    def method_missing(m, *args)
      @disk[@name].send(m, *args)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42C', %w(
  kata_create() does NOT raise when the id is provided
  and contains the letter L (ell, lowercase or uppercase)
  (this is for backward compatibility; katas in storer
  have ids with ells and I want porter to have to only map
  ids that are not unique in their first 6 characters)
  ) do
    manifest = starter.manifest
    ell = 'L'

    id = '12345' + ell.upcase
    manifest['id'] = id
    assert_equal id, kata_create(manifest)

    id = '12345' + ell.downcase
    manifest['id'] = id
    assert_equal id, kata_create(manifest)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '422', %w(
  kata_create(manifest) uses a given id
  when the id does not already exist ) do
    explicit_id = 'CE2BD6'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = kata_create(manifest)
    assert_equal explicit_id, id
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '423', %w(
  kata_create(manifest) raises
  when it is passed an id that already exists ) do
    explicit_id = 'A01DE8'
    manifest = starter.manifest
    manifest['id'] = explicit_id
    id = kata_create(manifest)
    assert_equal explicit_id, id

    manifest = starter.manifest
    manifest['id'] = id
    error = assert_raises(ArgumentError) {
      kata_create(manifest)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42D',
  'kata_manifest raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata_manifest(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '42E',
  'create/manifest round-trip' do
    m = starter.manifest
    m['id'] = '0ADDE7'
    id = kata_create(m.clone)
    assert_equal '0ADDE7', id
    assert_equal m, kata_manifest(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_ran_tests(id,...), kata_tags(id), kata_tag(id,n)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '821',
  'kata_tags raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata_tags(id)
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '822',
  'kata_tag raises when n does not exist' do
    id = stub_kata_create('AB5AEE')
    error = assert_raises(ArgumentError) {
      kata_tag(id, 1)
    }
    assert_equal 'n:invalid:1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '823',
  'ran_tests raises when id does not exist' do
    id = 'B4AB37'
    error = assert_raises(ArgumentError) {
      kata_ran_tests(*make_args(id, 1, edited_files))
    }
    assert_equal "id:invalid:#{id}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '824', %w(
  kata_ran_tests raises when n is -1
  because -1 can only be used on tag()
  ) do
    id = stub_kata_create('FCF211')
    error = assert_raises(ArgumentError) {
      kata_ran_tests(*make_args(id, -1, edited_files))
    }
    assert_equal 'n:invalid:-1', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '825', %w(
  kata_ran_tests raises when n is 0
  because 0 is used for kata_create()
  ) do
    id = stub_kata_create('08739D')
    error = assert_raises(ArgumentError) {
      kata_ran_tests(*make_args(id, 0, edited_files))
    }
    assert_equal 'n:invalid:0', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '826', %w(
  kata_ran_tests raises when n already exists
  and does not add a new tag,
  in other words it fails atomically ) do
    id = stub_kata_create('C7112B')
    expected = []
    expected << tags0
    assert_equal expected, kata_tags(id)

    kata_ran_tests(*make_args(id, 1, edited_files))
    expected << {
      'colour' => red,
      'time' => time_now,
      'number' => 1
    }
    assert_equal expected, kata_tags(id)

    error = assert_raises(ArgumentError) {
      kata_ran_tests(*make_args(id, 1, edited_files))
    }
    assert_equal 'n:invalid:1', error.message

    assert_equal expected, kata_tags(id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '827', %w(
  kata_ran_tests does NOT raise when n-1 does not exist
  and the reason for this is partly speed
  and partly robustness against temporary singler failure ) do
    id = stub_kata_create('710145')
    kata_ran_tests(*make_args(id, 1, edited_files))
    # ran_tests(*make_args(id, 2, ...)) assume failed
    kata_ran_tests(*make_args(id, 3, edited_files)) # <====
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '829',
  'after kata_ran_tests() there is one more tag' do
    id = stub_kata_create('9DD618')

    expected_tags = [tags0]
    diagnostic = '#0 kata_tags(id)'
    assert_equal expected_tags, kata_tags(id), diagnostic

    files = starter.manifest['visible_files']
    expected = rag_tag(files, '', '', 0)
    assert_equal expected, kata_tag(id, 0), 'kata_tag(id,0)'
    assert_equal expected, kata_tag(id, -1), 'kata_tag(id,-1)'

    kata_ran_tests(*make_args(id, 1, edited_files))

    expected_tags << {
      'colour' => red,
      'time'   => time_now,
      'number' => (now_tag=1)
    }
    diagnostic = '#1 kata_tags(id)'
    assert_equal expected_tags, kata_tags(id), diagnostic

    expected = rag_tag(edited_files, stdout, stderr, status)
    assert_equal expected, kata_tag(id, 1), 'kata_tag(id,1)'
    assert_equal expected, kata_tag(id, -1), 'kata_tag(id,-1)'
  end

  private

  def tags0
    {
      'event'  => 'created',
      'time'   => creation_time,
      'number' => 0
    }
  end

  def rag_tag(files, stdout, stderr, status)
    {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
  end

  def make_args(id, n, files)
    [ id, n, files, time_now, stdout, stderr, status, red ]
  end

  def edited_files
    { 'cyber-dojo.sh' => 'gcc',
      'hiker.c'       => '#include "hiker.h"',
      'hiker.h'       => '#ifndef HIKER_INCLUDED',
      'hiker.tests.c' => '#include <assert.h>'
    }
  end

  def time_now
    [2016,12,2, 6,14,57]
  end

  def stdout
    ''
  end

  def stderr
    'Assertion failed: answer() == 42'
  end

  def status
    23
  end

  def red
    'red'
  end

end