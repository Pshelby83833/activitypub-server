require './lib/service'

class AccountCreator < Service
  attribute :username
  attribute :display_name
  attribute :summary
  # TODO: icon media type?
  attribute :icon_url

  def call
    raise 'username already exists' if STORAGE.read(:accounts, id)

    account =
      {
        id: id,
        type: 'Person',
        following: "#{id}/following",
        followers: "#{id}/followers",
        inbox: "#{id}/inbox",
        outbox: "#{id}/outbox",
        featured: "#{id}/collections/featured",
        preferredUsername: username,
        name: display_name,
        summary: summary,
        url: id,
        manuallyApprovesFollowers: false,
        publicKey: {
          id: "#{id}#main-key",
          owner: id,
          publicKeyPem: public_key
        },
        tag: [],
        attachment: [],
        icon: {
          type: 'Image',
          mediaType: 'image/png',
          url: icon_url
        }
      }

    STORAGE.write(:accounts, id, account)
    STORAGE.write(:privateKeys, id, private_key)

    account
  end

  private

  def id
    @id ||= "#{BASE_URL}/users/#{username}"
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(2048)
  end

  def private_key
    @private_key ||= keypair.to_pem
  end

  def public_key
    @public_key ||= keypair.public_key.to_pem
  end
end
