# How to get PVC Usage
### All namespace
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/get-pvc-usage.sh | bash
```

### One namespace
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/get-pvc-usage.sh | bash -s <name_space>
```
# How to create Standard Security Group
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create-standard-sg.sh | bash -s <security_group_ID>
```

# How to create sudo user (Ubuntu)
Tạo user, cấp sudo NOPASSWD và add SSH public key. User đã tồn tại thì skip. User có sẵn: `nhdinh`, `lhhoang2`, `ndtnhan`, `dmnhat`.

Chạy **trên server Ubuntu** (cần Linux, bash >= 4), không chạy trên máy Mac.

### Chọn user từ menu
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh | sudo bash
```
```
Bạn muốn tạo user nào?
  1) nhdinh
  2) lhhoang2
  3) ndtnhan
  4) dmnhat
  5) all
Chọn (vd: 1 3, hoặc 5):
```

### Truyền sẵn user
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh | sudo bash -s -- <user1> <user2>
```

### Tất cả user
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh | sudo bash -s -- all
```

### Hướng dẫn
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh | bash -s -- -h
```

### Chạy từ máy khác qua ssh
Menu cần terminal, nên phải có `-t` (hoặc truyền sẵn user thay cho menu):
```
ssh -t <user>@<server-ip> 'curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/main/create_sudo_user.sh | sudo bash'
```

### Vừa push mà vẫn chạy bản cũ
GitHub cache link `main` vài phút. Thay `main` bằng commit SHA để lấy bản mới ngay:
```
curl -sL https://raw.githubusercontent.com/nhdinh39/bash-script-helpful/<commit-sha>/create_sudo_user.sh | sudo bash
```

### Thêm user mới
Thêm tên vào mảng `USERS` và `[tên]="<public key>"` vào `PUBKEYS` trong `create_sudo_user.sh`.
