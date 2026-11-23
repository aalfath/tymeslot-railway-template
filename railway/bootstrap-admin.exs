# Evaluated on the running Tymeslot node by bootstrap-admin.sh.
#
# Tymeslot makes the first sign-up the admin, but a new account can only log
# in after it confirms its email. With no SMTP configured (the template's
# default), that email is discarded, so the admin is created here instead,
# already verified, from ADMIN_EMAIL and ADMIN_PASSWORD. It runs only while the
# install has no verified admin, so later password or email changes made in the
# app are never overwritten.
import Ecto.Query

alias Tymeslot.Auth.UserSchema
alias Tymeslot.Repo

log = fn msg -> IO.puts("[railway-bootstrap] " <> msg) end

email = System.get_env("ADMIN_EMAIL", "") |> String.trim() |> String.downcase()
password = System.get_env("ADMIN_PASSWORD", "")

verified_admin? =
  Repo.exists?(from(u in UserSchema, where: u.is_admin and not is_nil(u.verified_at)))

cond do
  verified_admin? ->
    log.("a verified admin exists; nothing to do")

  email == "" or password == "" ->
    log.("ADMIN_EMAIL or ADMIN_PASSWORD is empty; skipping admin creation")

  true ->
    user =
      case Repo.get_by(UserSchema, email: email) do
        nil ->
          case Tymeslot.Auth.register_user(%{"email" => email, "password" => password},
                 ip: "127.0.0.1",
                 user_agent: "railway-bootstrap",
                 via: :provisioning
               ) do
            {:ok, user, _message} -> user
            other -> raise "admin registration failed: #{inspect(other)}"
          end

        existing ->
          existing
      end

    # Reset the password too: until a verified admin exists, an account with
    # this address may have been signed up by someone else.
    user
    |> Ecto.Changeset.change(
      password_hash: Tymeslot.Security.Password.hash_password(password),
      verified_at: DateTime.utc_now(:second),
      is_admin: true
    )
    |> Repo.update!()

    # A public instance should not accept strangers' sign-ups by default.
    # Admins can reopen registration at /admin.
    case Tymeslot.AppSettings.update(%{registration_enabled: false}) do
      {:ok, _settings} -> log.("public registration closed (reopen it at /admin)")
      other -> log.("could not close registration: #{inspect(other)}")
    end

    log.("admin account ready: #{email}")
end
