#!/usr/bin/env bash
# Tạo user Ubuntu, cấp sudo NOPASSWD và add SSH public key của user đó.
#
# Hướng dẫn: bash create_sudo_user.sh -h

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Script này chỉ chạy trên Linux (Ubuntu). Máy này là $(uname -s) — hãy ssh vào server rồi chạy." >&2
  exit 1
fi

if (( BASH_VERSINFO[0] < 4 )); then
  echo "Cần bash >= 4 (đang là ${BASH_VERSION})." >&2
  exit 1
fi

USERS=(nhdinh lhhoang2 ndtnhan dmnhat)

declare -A PUBKEYS=(
  [nhdinh]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxgaBHpmW6NcMQm2ymcfiEGfnZgPftlgOKXKWFBim6J nhdinh@rainscales.com"
  [lhhoang2]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKYqQO24CoDiYpA1IDZX7YGXw5k/2OllDmaVfhT+YD8 lhhoang2@gmail.com"
  [ndtnhan]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDK0Ffs59/jBiK/Dx8BF34uqvu1CEAYW4PvDe/+HEV9JcaZf+B4n2lKJrbvc6DYCccK0VwmVjbAt9QiSUnVnwvlCOnr/7YwKaVxD9kALyasQuckixWpQ/GpnMhzLK8UQ4Y5Kg9wtdSLoXsczPHzSyKcTySsQHjNZN839lvuisATWaw21cvcxlrCixYDmG/lr/Hg7xnZDAKv+HD+U1rfu9RU+dSojDfIY6Ud2fsvgE/Tiw5FKZeL1eIF6yCverxtn5w172Nfa48PlrAzYXW88etnBOBXJGEZPDyvkMfOXG71xz18SE/Qgwlirp4BOoNJcVzj5EUP6f2iNEgGdAOoapvOmKIYbpxZty6Dx5k3isrL4XqlbSNy2OmwBhqjoQSnn1m2j+b7/x7+ZzZ2uij8IY654gy//J9AY7yX4H1Ui7drwSER703gJcqx8GzpfZxlPCQdITpSMU4FfeUg0k/nod2KYd84DKucq7xCQzdA4fecAIlRg5Q1C8zAwrN2ho/FZ+hYlnH3vl376/rYnfUthvc93sgaxDP+cLtUtTM5ZHisGa3Ggf/9T/rfFHUfOgdgVA0sl5MO8HflE2SO8G0+6dzKZvbMmH9gRHbnLp6UMLa+W6k32wpRRO1Pho9F69S9365p7VzZF81IF/muTFvBZeKGnnMOoHouWbfDrjV0U3lrhw== ndtnhan"
  [dmnhat]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAfgBFo1yv0S+4cbI32vPBNHXq15SdbA/Zi4hzOjogR dmnhat"
)

RAW_URL="https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh"

usage() {
  cat <<EOF
Tạo user Ubuntu, cấp sudo NOPASSWD và add SSH public key. User đã tồn tại thì skip.

User có sẵn: ${USERS[*]}

Chọn user từ menu:
  curl -sL ${RAW_URL} | sudo bash

Truyền sẵn user:
  curl -sL ${RAW_URL} | sudo bash -s -- <user1> <user2>

Add tất cả:
  curl -sL ${RAW_URL} | sudo bash -s -- all

Hiện hướng dẫn này:
  curl -sL ${RAW_URL} | bash -s -- -h
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $EUID -ne 0 ]]; then
  echo "Phải chạy bằng root." >&2
  echo >&2
  usage >&2
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

ALL_CHOICE=$(( ${#USERS[@]} + 1 ))

prompt_users() {
  # Khi chạy qua `curl | bash`, stdin là script nên phải đọc từ /dev/tty.
  if ! { : < /dev/tty; } 2>/dev/null; then
    echo "Không có terminal để hỏi. Truyền user qua tham số: ... | sudo bash -s -- <user>" >&2
    exit 1
  fi

  echo "Bạn muốn tạo user nào?" > /dev/tty
  local i
  for i in "${!USERS[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${USERS[$i]}" > /dev/tty
  done
  printf "  %d) all\n" "$ALL_CHOICE" > /dev/tty
  printf "Chọn (vd: 1 3, hoặc %d): " "$ALL_CHOICE" > /dev/tty

  local answer
  read -r answer < /dev/tty
  read -ra args <<< "$answer"
}

args=("$@")
if [[ ${#args[@]} -eq 0 ]]; then
  prompt_users
fi

selected=()
for arg in "${args[@]}"; do
  if [[ "$arg" == "all" || "$arg" == "$ALL_CHOICE" ]]; then
    selected=("${USERS[@]}")
    break
  elif [[ "$arg" =~ ^[0-9]+$ ]] && (( arg >= 1 && arg <= ${#USERS[@]} )); then
    selected+=("${USERS[$((arg - 1))]}")
  elif [[ -n "${PUBKEYS[$arg]:-}" ]]; then
    selected+=("$arg")
  else
    echo "Lựa chọn không hợp lệ: '${arg}'. Chạy với -h để xem hướng dẫn." >&2
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

# sudo xoá SSH_CONNECTION khỏi env, nên đọc từ process cha (shell ssh gốc).
ssh_connection() {
  local pid=$$ conn
  while [[ -n "$pid" && "$pid" -gt 1 ]]; do
    conn=$(tr '\0' '\n' 2>/dev/null < "/proc/${pid}/environ" | sed -n 's/^SSH_CONNECTION=//p') || conn=""
    if [[ -n "$conn" ]]; then
      echo "$conn"
      return 0
    fi
    pid=$(awk '/^PPid:/ {print $2}' "/proc/${pid}/status" 2>/dev/null) || pid=""
  done
}

read -r _ _ server_ip server_port <<< "$(ssh_connection)" || true
port_opt=""
[[ -n "${server_port:-}" && "$server_port" != "22" ]] && port_opt="-p ${server_port} "

echo
echo "Hoàn tất. Đăng nhập bằng:"
for username in "${selected[@]}"; do
  echo "  ssh ${port_opt}${username}@${server_ip:-<server-ip>}"
done
