require_relative 'http_json_service'

class StarterService

  def manifest
    json = language_manifest(display_name, exercise_name)
    manifest = json['manifest']
    manifest['created'] = creation_time
    manifest['exercise'] = exercise_name
    manifest['visible_files']['readme.txt'] = json['exercise']
    manifest
  end

  def creation_time
    [ 2016,12,15, 17,26,34 ]
  end

  private

  include HttpJsonService

  def language_manifest(display_name, exercise_name)
    get(__method__, display_name, exercise_name)
  end

  def display_name
    'C (gcc), assert'
  end

  def exercise_name
    'Fizz_Buzz'
  end

  def hostname
    'starter'
  end

  def port
    4527
  end

end