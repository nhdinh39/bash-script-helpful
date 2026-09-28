#!/usr/bin/env bash
# Tạo user Ubuntu, cấp sudo NOPASSWD và add SSH public key của user đó.
#
# Cách dùng:
#   curl -fsSL <RAW_URL> | sudo bash                      # hỏi user cần add
#   curl -fsSL <RAW_URL> | sudo bash -s -- lhhoang2 dmnhat # truyền sẵn user
#   curl -fsSL <RAW_URL> | sudo bash -s -- all            # add tất cả
#   sudo bash create_sudo_user.sh [user...|all]

set -euo pipefail

USERS=(nhdinh lhhoang2 ndtnhan dmnhat)

declare -A PUBKEYS=(
  [nhdinh]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxgaBHpmW6NcMQm2ymcfiEGfnZgPftlgOKXKWFBim6J nhdinh@rainscales.com"
  [lhhoang2]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKYqQO24CoDiYpA1IDZX7YGXw5k/2OllDmaVfhT+YD8 lhhoang2@gmail.com"
  [ndtnhan]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK0Ffs59/jBiK/Dx8BF34uqvu1CEAYW4PvDe/+HEV9JcaZf+B4n2lKJrbvc6DYCccK0VwmVjbAt9QiSUnVnwvlCOnr/7YwKaVxD9kALyasQuckixWpQ/GpnMhzLK8UQ4Y5Kg9wtdSLoXsczPHzSyKcTySsQHjNZN839lvuisATWaw21cvcxlrCixYDmG/lr/Hg7xnZDAKv+HD+U1rfu9RU+dSojDfIY6Ud2fsvgE/Tiw5FKZeL1eIF6yCverxtn5w172Nfa48PlrAzYXW88etnBOBXJGEZPDyvkMfOXG71xz18SE/Qgwlirp4BOoNJcVzj5EUP6f2iNEgGdAOoapvOmKIYbpxZty6Dx5k3isrL4XqlbSNy2OmwBhqjoQSnn1m2j+b7/x7+ZzZ2uij8IY654gy//J9AY7yX4H1Ui7drwSER703gJcqx8GzpfZxlPCQdITpSMU4FfeUg0k/nod2KYd84DKucq7xCQzdA4fecAIlRg5Q1C8zAwrN2ho/FZ+hYlnH3vl376/rYnfUthvc93sgaxDP+cLtUtTM5ZHisGa3Ggf/9T/rfFHUfOgdgVA0sl5MO8HflE2SO8G0+6dzKZvbMmH9gRHbnLp6UMLa+W6k32wpRRO1Pho9F69S9365p7VzZF81IF/muTFvBZeKGnnMOoHouWbfDrjV0U3lrhw== ndtnhan"
  [dmnhat]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAfgBFo1yv0S+4cbI32vPBNHXq15SdbA/Zi4hzOjogR dmnhat"
)

if [[ $EUID -ne 0 ]]; then
  echo "Phải chạy bằng root: curl -fsSL <url> | sudo bash" >&2
  exit 1
fi

create_user() {
  local username="$1"
  local pubkey="${PUBKEYS[$username]}"

  echo "==> ${username}"

  if id "$username" &>/dev/null; then
    echo "    User đã tồn tại, skip."
    return 0
  fi

  useradd --create-home --shell /bin/bash "$username"
  echo "    Đã tạo user."

  # visudo check trên file tạm trước, file sudoers lỗi sẽ làm hỏng sudo toàn máy.
  local sudoers_file="/etc/sudoers.d/90-${username}-nopasswd"
  local tmp_sudoers
  tmp_sudoers=$(mktemp)
  echo "${username} ALL=(ALL) NOPASSWD:ALL" > "$tmp_sudoers"
  visudo -cqf "$tmp_sudoers"
  install -m 0440 -o root -g root "$tmp_sudoers" "$sudoers_file"
  rm -f "$tmp_sudoers"
  echo "    Đã cấp sudo NOPASSWD."

  local user_home ssh_dir auth_keys
  user_home=$(getent passwd "$username" | cut -d: -f6)
  ssh_dir="${user_home}/.ssh"
  auth_keys="${ssh_dir}/authorized_keys"

  install -d -m 700 -o "$username" -g "$username" "$ssh_dir"

  echo "$pubkey" > "$auth_keys"
  echo "    Đã thêm public key."

  chmod 600 "$auth_keys"
  chown "${username}:${username}" "$auth_keys"
}

prompt_users() {
  # Khi chạy qua `curl | bash`, stdin là script nên phải đọc từ /dev/tty.
  if [[ ! -r /dev/tty ]]; then
    echo "Không có terminal để hỏi. Truyền user qua tham số: ... | sudo bash -s -- <user>" >&2
    exit 1
  fi

  echo "User có sẵn:" > /dev/tty
  local i
  for i in "${!USERS[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${USERS[$i]}" > /dev/tty
  done
  echo "  a) tất cả" > /dev/tty

  local answer
  read -rp "Chọn user (số hoặc tên, cách nhau bởi dấu cách): " answer < /dev/tty
  echo "$answer"
}

args=("$@")
if [[ ${#args[@]} -eq 0 ]]; then
  read -ra args <<< "$(prompt_users)"
fi

selected=()
for arg in "${args[@]}"; do
  if [[ "$arg" == "a" || "$arg" == "all" ]]; then
    selected=("${USERS[@]}")
    break
  elif [[ "$arg" =~ ^[0-9]+$ ]] && (( arg >= 1 && arg <= ${#USERS[@]} )); then
    selected+=("${USERS[$((arg - 1))]}")
  elif [[ -n "${PUBKEYS[$arg]:-}" ]]; then
    selected+=("$arg")
  else
    echo "Không biết user '${arg}'. Có: ${USERS[*]}" >&2
    exit 1
  fi
done

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Chưa chọn user nào." >&2
  exit 1
fi

for username in "${selected[@]}"; do
  create_user "$username"
done

ip=$(hostname -I 2>/dev/null | awk '{print $1}')
echo
echo "Hoàn tất. Đăng nhập bằng:"
for username in "${selected[@]}"; do
  echo "  ssh ${username}@${ip:-<server-ip>}"
done
