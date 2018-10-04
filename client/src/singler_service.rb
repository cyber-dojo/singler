require_relative 'http_json_service'

class SinglerService

  def sha
    get(__method__)
  end

  # - - - - - - - - - - - -

  def create(manifest, files)
    post(__method__, manifest, files)
  end

  def manifest(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def id?(id)
    get(__method__, id)
  end

  def id_completed(partial_id)
    get(__method__, partial_id)
  end

  def id_completions(outer_id)
    get(__method__, outer_id)
  end

  # - - - - - - - - - - - -

  def ran_tests(id, files, now, stdout, stderr, status, colour)
    post(__method__, id, files, now, stdout, stderr, status, colour)
  end

  def tags(id)
    get(__method__, id)
  end

  # - - - - - - - - - - - -

  def visible_files(id)
    get(__method__, id)
  end

  def tag_visible_files(id, tag)
    get(__method__, id, tag)
  end

  def tags_visible_files(id, was_tag, now_tag)
    get(__method__, id, was_tag, now_tag)
  end

  private

  include HttpJsonService

  def hostname
    'singler'
  end

  def port
    4517
  end

end
