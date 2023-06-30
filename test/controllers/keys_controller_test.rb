require 'test_helper'

class KeysControllerTest < ActionDispatch::IntegrationTest
  test 'creates key if asking for current and not generated' do
    KeysController.any_instance.stubs(:token).returns(
      {
        'aud' => 'http://www.example.com/oid/current',
        '_oase_id' => 'oid',
        '_participant_id' => 'pid',
        'sub' => 'current',
        'exp' => Time.now.to_i + 1000,
        'iss' => 'https://api.oase.app'
      }
    )
    get('/oid/current')
    assert_equal response.status, 200
    json = JSON.parse(response.body)
    assert json['key']
    assert json['kid']
  end

  test 'returns exisiting key if asking for current' do
    kid = SecureRandom.uuid
    oid = 'oid'
    Key.create!(value: 'a', oase_id: oid)
    Key.create!(id: kid, value: '1', oase_id: oid)
    KeysController.any_instance.stubs(:token).returns(
      {
        'aud' => 'http://www.example.com/oid/current',
        '_oase_id' => oid,
        '_participant_id' => 'pid',
        'sub' => 'current',
        'exp' => Time.now.to_i + 1000,
        'iss' => 'https://api.oase.app'
      }
    )
    get('/oid/current')
    assert_equal response.status, 200
    json = JSON.parse(response.body)
    assert_equal '1', json['key']
    assert_equal kid, json['kid']
  end

  test 'getting specific key' do
    kid = SecureRandom.uuid
    oid = 'oid'
    Key.create!(id: kid, value: '1', oase_id: oid)
    KeysController.any_instance.stubs(:token).returns(
      {
        'aud' => "http://www.example.com/oid/#{kid}",
        '_oase_id' => oid,
        '_participant_id' => 'pid',
        'sub' => kid,
        'exp' => Time.now.to_i + 1000,
        'iss' => 'https://api.oase.app'
      }
    )
    get("/oid/#{kid}")
    assert_equal response.status, 200
    json = JSON.parse(response.body)
    assert_equal '1', json['key']
    assert_equal kid, json['kid']
  end

  test 'creating key' do
    oase_id = SecureRandom.uuid
    post("/#{oase_id}")
    assert_equal response.status, 201
    assert_empty response.body
    assert_equal 1, Key.where(oase_id: oase_id).count
    assert_equal 1, Key.count
  end
end
