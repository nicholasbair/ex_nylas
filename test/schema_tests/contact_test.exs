defmodule ExNylas.ContactTest do
  use ExUnit.Case, async: true
  alias ExNylas.Contact

  describe "Contact schema" do
    test "creates a valid contact with basic fields" do
      params = %{
        "id" => "contact_123",
        "given_name" => "John",
        "company_name" => "Acme Corp",
        "job_title" => "Software Engineer",
        "grant_id" => "grant_456"
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert contact.id == "contact_123"
      assert contact.given_name == "John"
      assert contact.company_name == "Acme Corp"
      assert contact.job_title == "Software Engineer"
      assert contact.grant_id == "grant_456"
    end

    test "validates source enum values" do
      valid_sources = ["address_book", "domain", "inbox"]

      for source <- valid_sources do
        params = %{"source" => source}
        changeset = Contact.changeset(%Contact{}, params)
        assert changeset.valid?, "Source #{source} should be valid"
      end
    end

    test "rejects invalid source values" do
      invalid_sources = ["external", "manual", "invalid"]

      for source <- invalid_sources do
        params = %{"source" => source}
        changeset = Contact.changeset(%Contact{}, params)
        refute changeset.valid?, "Source #{source} should be invalid"
        event = Ecto.Changeset.apply_changes(changeset)
        assert event.source == nil
      end
    end

    test "handles string fields correctly" do
      params = %{
        "birthday" => "1990-01-01",
        "manager_name" => "Jane Smith",
        "notes" => "Important contact",
        "office_location" => "Building A, Floor 3"
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert contact.birthday == "1990-01-01"
      assert contact.manager_name == "Jane Smith"
      assert contact.notes == "Important contact"
      assert contact.office_location == "Building A, Floor 3"
    end
  end

  describe "Contact emails" do
    test "creates contact with emails" do
      params = %{
        "given_name" => "John Doe",
        "emails" => [
          %{
            "email" => "john@example.com",
            "type" => "work"
          },
          %{
            "email" => "john.doe@personal.com",
            "type" => "personal"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.emails) == 2

      [email1, email2] = contact.emails
      assert email1.email == "john@example.com"
      assert email1.type == "work"
      assert email2.email == "john.doe@personal.com"
      assert email2.type == "personal"
    end

    test "handles empty emails array" do
      params = %{
        "given_name" => "John Doe",
        "emails" => []
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert contact.emails == []
    end
  end

  describe "Contact phone numbers" do
    test "creates contact with phone numbers" do
      params = %{
        "given_name" => "John Doe",
        "phone_numbers" => [
          %{
            "number" => "+1-555-123-4567",
            "type" => "work"
          },
          %{
            "number" => "+1-555-987-6543",
            "type" => "mobile"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.phone_numbers) == 2

      [phone1, phone2] = contact.phone_numbers
      assert phone1.number == "+1-555-123-4567"
      assert phone1.type == :work
      assert phone2.number == "+1-555-987-6543"
      assert phone2.type == :mobile
    end

    test "validates phone number type enum values" do
      valid_types = ["work", "home", "other", "mobile"]

      for type <- valid_types do
        params = %{
          "phone_numbers" => [
            %{"number" => "+1-555-123-4567", "type" => type}
          ]
        }
        changeset = Contact.changeset(%Contact{}, params)
        assert changeset.valid?, "Phone number type #{type} should be valid"
      end
    end

    test "rejects invalid phone number type values" do
      invalid_types = ["fax", "pager", "invalid"]

      for type <- invalid_types do
        params = %{
          "phone_numbers" => [
            %{"number" => "+1-555-123-4567", "type" => type}
          ]
        }
        changeset = Contact.changeset(%Contact{}, params)
        refute changeset.valid?, "Phone number type #{type} should be invalid"
        event = Ecto.Changeset.apply_changes(changeset)
        assert event.phone_numbers |> List.first() |> Map.get(:type) == nil
      end
    end
  end

  describe "Contact web pages" do
    test "creates contact with web pages" do
      params = %{
        "given_name" => "John Doe",
        "web_pages" => [
          %{
            "url" => "https://linkedin.com/in/johndoe",
            "type" => "work"
          },
          %{
            "url" => "https://twitter.com/johndoe",
            "type" => "other"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.web_pages) == 2

      [web1, web2] = contact.web_pages
      assert web1.url == "https://linkedin.com/in/johndoe"
      assert web1.type == :work
      assert web2.url == "https://twitter.com/johndoe"
      assert web2.type == :other
    end

    test "validates web page type enum values" do
      valid_types = ["work", "home", "other"]

      for type <- valid_types do
        params = %{
          "web_pages" => [
            %{"url" => "https://example.com", "type" => type}
          ]
        }
        changeset = Contact.changeset(%Contact{}, params)
        assert changeset.valid?, "Web page type #{type} should be valid"
      end
    end

    test "rejects invalid web page type values" do
      invalid_types = ["social", "blog", "invalid"]

      for type <- invalid_types do
        params = %{
          "web_pages" => [
            %{"url" => "https://example.com", "type" => type}
          ]
        }
        changeset = Contact.changeset(%Contact{}, params)
        refute changeset.valid?, "Web page type #{type} should be invalid"
        event = Ecto.Changeset.apply_changes(changeset)
        assert event.web_pages |> List.first() |> Map.get(:type) == nil
      end
    end
  end

  describe "Contact groups" do
    test "creates contact with groups" do
      params = %{
        "given_name" => "John Doe",
        "groups" => [
          %{
            "id" => "group_123",
            "name" => "Work Contacts"
          },
          %{
            "id" => "group_456",
            "name" => "Family"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.groups) == 2

      [group1, group2] = contact.groups
      assert group1.id == "group_123"
      assert group1.name == "Work Contacts"
      assert group2.id == "group_456"
      assert group2.name == "Family"
    end
  end

  describe "Contact IM addresses" do
    test "creates contact with IM addresses" do
      params = %{
        "given_name" => "John Doe",
        "im_addresses" => [
          %{
            "im_address" => "johndoe@jabber.org",
            "type" => "jabber"
          },
          %{
            "im_address" => "johndoe@skype.com",
            "type" => "skype"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.im_addresses) == 2

      [im1, im2] = contact.im_addresses
      assert im1.im_address == "johndoe@jabber.org"
      assert im1.type == "jabber"
      assert im2.im_address == "johndoe@skype.com"
      assert im2.type == "skype"
    end
  end

  describe "Contact physical addresses" do
    test "creates contact with physical addresses" do
      params = %{
        "given_name" => "John Doe",
        "physical_addresses" => [
          %{
            "street_address" => "123 Main St",
            "city" => "Anytown",
            "state" => "CA",
            "postal_code" => "12345",
            "country" => "USA",
            "type" => "work"
          }
        ]
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert length(contact.physical_addresses) == 1

      [address] = contact.physical_addresses
      assert address.street_address == "123 Main St"
      assert address.city == "Anytown"
      assert address.state == "CA"
      assert address.postal_code == "12345"
      assert address.country == "USA"
      assert address.type == "work"
    end
  end

  describe "Contact edge cases" do
    test "handles nil values gracefully" do
      params = %{
        "given_name" => "John Doe",
        "company_name" => nil,
        "job_title" => nil,
        "birthday" => nil
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert contact.given_name == "John Doe"
      assert contact.company_name == nil
      assert contact.job_title == nil
      assert contact.birthday == nil
    end

    test "handles empty arrays" do
      params = %{
        "given_name" => "John Doe",
        "emails" => [],
        "phone_numbers" => [],
        "groups" => [],
        "im_addresses" => [],
        "physical_addresses" => [],
        "web_pages" => []
      }

      changeset = Contact.changeset(%Contact{}, params)
      assert changeset.valid?

      contact = Ecto.Changeset.apply_changes(changeset)
      assert contact.emails == []
      assert contact.phone_numbers == []
      assert contact.groups == []
      assert contact.im_addresses == []
      assert contact.physical_addresses == []
      assert contact.web_pages == []
    end
  end
end
