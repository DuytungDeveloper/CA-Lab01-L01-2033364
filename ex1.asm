# ==============================================================================
# BÀI 1: NHẬP TÊN VÀ IN LỜI CHÀO "Hello <name>!" (CÓ BẮT NGOẠI LỆ)
# ==============================================================================
#
# 1. LIÊN HỆ VỚI NGÔN NGỮ C / C#:
#    - Tương đương trong C#:
#         string name = Console.ReadLine();
#         if (string.IsNullOrWhiteSpace(name)) {
#             Console.WriteLine("Error: Name cannot be empty!");
#             return;
#         }
#         Console.WriteLine($"Hello, {name}!");
#
#    - Tương đương trong C:
#         char buffer[100];
#         fgets(buffer, 100, stdin);
#         if (buffer[0] == '\n' || buffer[0] == '\0') {
#             printf("Error: Name cannot be empty!\n");
#             return 1;
#         }
#         // Xóa ký tự '\n' và thay bằng '!'...
#
# 2. XỬ LÝ NGOẠI LỆ TRONG BÀI:
#    - Ngoại lệ 1: Người dùng không nhập gì mà ấn Enter ngay (chuỗi rỗng).
#      Ký tự đầu tiên `buffer[0]` sẽ là '\n' (mã ASCII 10) hoặc '\0'.
#      Chương trình sẽ bắt lỗi và in: "Error: Name cannot be empty!" rồi thoát an toàn.
#    - Ngoại lệ 2: Người dùng nhập quá 100 ký tự (Buffer Overflow).
#      Được giới hạn an toàn bằng cách truyền $a1 = 100 cho Syscall 8 (bộ đệm nhận tối đa 99 ký tự và kết thúc bằng '\0').
#
# 3. QUY ƯỚC THANH GHI:
#    - $v0 : Mã Syscall (4 = in chuỗi, 8 = đọc chuỗi, 10 = thoát)
#    - $a0 : Tham số địa chỉ chuỗi
#    - $a1 : Độ dài tối đa bộ đệm (100 bytes)
#    - $t0 : Con trỏ duyệt mảng ký tự
#    - $t1 : Giá trị ký tự đang xét
#
# 4. GIẢI THÍCH CÁC CHỈ THỊ VÀ CÚ PHÁP ĐỊNH ĐỊA CHỈ (GIÁO TRÌNH CO2007 - CHƯƠNG 2 & PHỤ LỤC A):
#    - `.data` (Chỉ thị trình dịch - Assembler Directive, Mục 2.10 & Phụ lục A):
#         Báo cho trình dịch biết đây là Phân vùng dữ liệu tĩnh (Static Data Segment, bắt đầu từ
#         địa chỉ 0x10010000). Dùng để khai báo biến, hằng chuỗi (.asciiz) và cấp phát vùng đệm (.space).
#    - `.text` (Chỉ thị trình dịch - Assembler Directive, Mục 2.10 & Phụ lục A):
#         Báo cho trình dịch biết đây là Phân vùng mã lệnh (Text/Code Segment, bắt đầu từ địa chỉ
#         0x00400000). Các lệnh sau đó sẽ được dịch thành mã máy nhị phân 32-bit và đặt ở chế độ chỉ đọc.
#    - `.globl main` (Khai báo ký hiệu toàn cục, Mục 2.10):
#         Công bố nhãn `main` ra bảng ký hiệu toàn cục (Global Symbol Table) để Linker và trình nạp
#         (Simulator MARS) xác định được điểm vào thực thi (Entry Point) của chương trình.
#    - `main:` (Nhãn điểm vào - Entry Point Label, Mục 2.3 & Phụ lục A):
#         Đại diện cho địa chỉ ô nhớ chứa lệnh đầu tiên của chương trình trong phân vùng Text.
#         Assembler sẽ thay thế nhãn `main` bằng địa chỉ bộ nhớ thực tế khi hợp dịch.
#    - `remove_nl:` (Nhãn nội bộ - Internal/Local Label, Mục 2.6):
#         Đánh dấu vị trí dòng lệnh làm đích nhảy cho các lệnh rẽ nhánh (`j remove_nl`, `beq`),
#         phục vụ việc tạo cấu trúc lặp duyệt chuỗi ở mức hợp ngữ.
#    - `0($t0)` (Chế độ định địa chỉ Cơ sở - Base Addressing / Displacement Addressing, Mục 2.5):
#         Cú pháp tổng quát: `offset(base_register)`. Ở đây offset = 0, thanh ghi cơ sở là $t0.
#         Địa chỉ hiệu dụng truy xuất = giá trị trong $t0 + 0 (đọc/ghi chính xác byte tại vị trí con trỏ $t0).
# ==============================================================================

.data
    # Phân vùng dữ liệu tĩnh (Static Data Segment - địa chỉ 0x10010000)
    prompt:     .asciiz "Please enter your name: "
    hello_msg:  .asciiz "Hello, "
    err_empty:  .asciiz "Error: Name cannot be empty!\n"
    buffer:     .space 100            # Cấp phát 100 bytes trong RAM
    newline:    .asciiz "\n"

.text
    # Phân vùng mã lệnh (Text Segment - địa chỉ 0x00400000)
.globl main     # Xuất nhãn main ra toàn cục để Linker/Loader nhận diện Entry Point

main:           # Nhãn đánh dấu lệnh thực thi đầu tiên của chương trình
    # --------------------------------------------------------------------------
    # BƯỚC 1: In câu nhắc nhập tên
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, prompt
    syscall

    # --------------------------------------------------------------------------
    # BƯỚC 2: Đọc chuỗi tên từ bàn phím vào buffer
    # --------------------------------------------------------------------------
    li   $v0, 8             # Syscall 8: read_string
    la   $a0, buffer        # Địa chỉ buffer nhận chuỗi
    li   $a1, 100           # Giới hạn an toàn chống tràn bộ nhớ: tối đa 100 bytes
    syscall

    # --------------------------------------------------------------------------
    # BƯỚC 3: BẮT NGOẠI LỆ - Kiểm tra chuỗi có bị rỗng không?
    # Tương đương C#: if (string.IsNullOrEmpty(buffer)) ...
    # --------------------------------------------------------------------------
    la   $t0, buffer        # Con trỏ $t0 trỏ vào byte đầu tiên của buffer
    lb   $t1, 0($t0)        # Định địa chỉ cơ sở 0($t0): Đọc 1 byte tại ($t0 + 0) vào $t1
    beq  $t1, 10, error_empty   # Nếu ký tự đầu là '\n' (mã 10, tức người dùng chỉ bấm Enter)
    beqz $t1, error_empty       # Hoặc nếu ký tự đầu là '\0' (rỗng hoàn toàn)

    # --------------------------------------------------------------------------
    # BƯỚC 4: Duyệt chuỗi tìm '\n' để thay thế bằng '!' (mã 33)
    # --------------------------------------------------------------------------
remove_nl:                  # Nhãn nội bộ: Điểm bắt đầu vòng lặp duyệt từng byte chuỗi
    lb   $t1, 0($t0)        # Định địa chỉ cơ sở 0($t0): Đọc 1 byte tại con trỏ $t0
    beqz $t1, print_hello   # Gặp '\0' thì dừng duyệt
    beq  $t1, 10, replace_nl# Gặp '\n' thì nhảy đến thay thế
    addi $t0, $t0, 1        # Tăng con trỏ sang byte tiếp theo
    j    remove_nl          # Nhảy không điều kiện quay lại nhãn remove_nl

replace_nl:
    li   $t2, 33            # Mã ASCII của '!' là 33
    sb   $t2, 0($t0)        # Định địa chỉ cơ sở 0($t0): Ghi đè 1 byte '!' vào vị trí con trỏ $t0
    sb   $zero, 1($t0)      # Ghi '\0' liền sau dấu '!' (Offset = 1 byte: 1($t0))

print_hello:
    # In "Hello, "
    li   $v0, 4
    la   $a0, hello_msg
    syscall

    # In tên kèm dấu '!'
    li   $v0, 4
    la   $a0, buffer
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # Thoát bình thường
    li   $v0, 10
    syscall

# ------------------------------------------------------------------------------
# XỬ LÝ NGOẠI LỆ: In thông báo lỗi khi tên bị rỗng
# ------------------------------------------------------------------------------
error_empty:
    li   $v0, 4
    la   $a0, err_empty     # In "Error: Name cannot be empty!\n"
    syscall

    li   $v0, 10            # Thoát chương trình an toàn
    syscall
