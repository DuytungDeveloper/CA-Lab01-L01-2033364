# ==============================================================================
# BÀI 5: IN ĐẢO NGƯỢC MẢNG 10 SỐ NGUYÊN KHỞI TẠO TRƯỚC (STATIC ARRAY)
# ==============================================================================
#
# 1. LIÊN HỆ VỚI NGÔN NGỮ C / C#:
#    - Tương đương trong C:
#         #include <stdio.h>
#         int main() {
#             int array[10] = {1, 2, 5, 8, 12, 44, 3, 9, 0, 10};
#             // In đảo ngược tuần tự từ index 9 về index 0:
#             for (int i = 9; i >= 0; i--) {
#                 printf("%d", array[i]);
#                 if (i > 0) printf(", ");
#                 else printf("\n");
#             }
#             return 0;
#         }
#
#    - Tương đương trong C#:
#         int[] array = {1, 2, 5, 8, 12, 44, 3, 9, 0, 10};
#         Console.WriteLine(string.Join(", ", array.Reverse()));
#
# 2. VÍ DỤ MINH HỌA BẢNG ĐỘ LỆCH BỘ NHỚ (BYTE OFFSET):
#    - Mảng trong MIPS được lưu bằng chỉ thị `.word`: mỗi phần tử là 1 số nguyên 32-bit = 4 bytes.
#    - Mảng 10 phần tử chiếm đúng 10 * 4 = 40 bytes liên tục trong RAM.
#    - Giả sử địa chỉ đầu mảng lưu trong $s0 (tương đương int *s0 = array trong C):
#        array[0] (giá trị 1)  -> Nằm tại: $s0 + (0 * 4)  = $s0 + 0  bytes
#        array[1] (giá trị 2)  -> Nằm tại: $s0 + (1 * 4)  = $s0 + 4  bytes
#        array[2] (giá trị 5)  -> Nằm tại: $s0 + (2 * 4)  = $s0 + 8  bytes
#        array[3] (giá trị 8)  -> Nằm tại: $s0 + (3 * 4)  = $s0 + 12 bytes
#        array[4] (giá trị 12) -> Nằm tại: $s0 + (4 * 4)  = $s0 + 16 bytes
#        array[5] (giá trị 44) -> Nằm tại: $s0 + (5 * 4)  = $s0 + 20 bytes
#        array[6] (giá trị 3)  -> Nằm tại: $s0 + (6 * 4)  = $s0 + 24 bytes
#        array[7] (giá trị 9)  -> Nằm tại: $s0 + (7 * 4)  = $s0 + 28 bytes
#        array[8] (giá trị 0)  -> Nằm tại: $s0 + (8 * 4)  = $s0 + 32 bytes
#        array[9] (giá trị 10) -> Nằm tại: $s0 + (9 * 4)  = $s0 + 36 bytes
#
#    - QUY TRÌNH ĐẢO NGƯỢC (PHƯƠNG ÁN 1 - TRẢI MÃ TUẦN TỰ):
#      Áp dụng kỹ thuật trải mã (Loop Unrolling): Đọc tuần tự từ offset 36 lùi dần về offset 0:
#        Lần 1: lw $a0, 36($s0) -> đọc số 10, in 10 kèm dấu ", "
#        Lần 2: lw $a0, 32($s0) -> đọc số 0,  in 0  kèm dấu ", "
#        Lần 3: lw $a0, 28($s0) -> đọc số 9,  in 9  kèm dấu ", "
#        ...
#        Lần 10: lw $a0, 0($s0) -> đọc số 1,  in 1  (phần tử cuối không in dấu phẩy)
#      => Kết quả in ra: 10, 0, 9, 3, 44, 12, 8, 5, 2, 1.
#
#    - VỀ TÍNH AN TOÀN NGOẠI LỆ:
#      Bài 5 không nhận dữ liệu từ người dùng (User Input = None).
#      Mảng được khai báo tĩnh (Static Data) và các chỉ số offset được xác định cố định
#      trong các lệnh `lw` từ offset 36 về 0. Do đó chương trình không gặp lỗi
#      truy xuất ngoài ranh giới mảng hay lỗi chia cho 0 trong thời gian chạy.
#
# ==============================================================================
# 3. PHÂN TÍCH TRƯỜNG HỢP DỮ LIỆU VƯỢT DẢI 32-BIT:
# ==============================================================================
#
#    1. Xét theo thiết kế tĩnh của đề bài:
#       - Chương trình không nhận input từ bàn phím trong quá trình thực thi.
#       - Các phần tử mảng được khai báo trong phân vùng `.data` bằng chỉ thị `.word`:
#             array: .word 1, 2, 5, 8, 12, 44, 3, 9, 0, 10
#       - Nếu người lập trình khai báo một giá trị vượt quá miền biểu diễn số nguyên 32-bit có dấu
#         [-2^31, 2^31 - 1] (ví dụ: .word 5000000000):
#         Trình dịch MARS sẽ phát hiện và báo lỗi ngay tại pha hợp dịch (Assemble-time Error):
#             "Error in ex5.asm: '5000000000' is not a valid 32-bit integer"
#         => Chương trình không thể hợp dịch thành mã máy để thực thi.
#
#    2. Xét kịch bản mở rộng (nhập mảng động từ bàn phím):
#       - Nếu bài toán yêu cầu nhập 10 phần tử từ bàn phím qua `syscall 5`:
#         * Tầng 1 (Kernel Runtime): Nếu người dùng nhập số vượt 32-bit hoặc ký tự chữ,
#           `syscall 5` của MARS sẽ kích hoạt ngoại lệ `invalid integer input (syscall 5)`
#           và dừng thực thi, ngăn giá trị sai lọt vào thanh ghi hoặc ô nhớ.
#         * Tầng 2 (Lưu trữ và in ấn): Vì chương trình chỉ nạp (`lw`) và in ra màn hình (`syscall 1`),
#           không thực hiện phép toán số học trên các phần tử mảng, nên không phát sinh hiện tượng
#           tràn số trong quá trình tính toán.
#
# ==============================================================================
# 4. QUY ƯỚC THANH GHI:
#    - $s0 : Lưu địa chỉ cơ sở (Base Address) của mảng array trong RAM
#    - $a0 : Chứa giá trị số nguyên cần in hoặc địa chỉ chuỗi phân cách ", "
#    - $v0 : Mã Syscall (1 = in số nguyên, 4 = in chuỗi, 10 = thoát)
#
# 5. KIẾN THỨC NỀN TẢNG (GIÁO TRÌNH CO2007 - CHƯƠNG 2 & PHỤ LỤC A):
#    - `.data` (Chỉ thị phân vùng dữ liệu tĩnh, Mục 2.10): Chứa mảng khởi tạo trước (0x10010000).
#    - `.text` (Chỉ thị phân vùng mã lệnh, Mục 2.10): Chứa các lệnh máy thực thi (0x00400000).
#    - `.globl main` (Mục 2.10): Khai báo nhãn toàn cục cho điểm vào chương trình.
#    - `main:` (Mục 2.3): Nhãn đánh dấu lệnh khởi đầu thực thi.
#    - `offset($s0)` (Chế độ định địa chỉ Cơ sở - Base Addressing, Mục 2.5):
#         Địa chỉ hiệu dụng = $s0 + offset. Ví dụ: `36($s0)` đọc 4 bytes của phần tử thứ 10.
# ==============================================================================

.data
    # Phân vùng dữ liệu tĩnh (Static Data Segment)
    # Căn chỉnh ranh giới từ nhớ (Word Alignment - bội số 4 bytes)
    .align 2
    # Khởi tạo mảng 10 phần tử theo đúng dữ liệu mẫu của đề bài
    array:      .word 1, 2, 5, 8, 12, 44, 3, 9, 0, 10
    sep:        .asciiz ", "      # Dấu phân cách giữa các phần tử
    newline:    .asciiz "\n"      # Ký tự xuống dòng kết thúc

.text
.globl main     # Khai báo nhãn toàn cục cho điểm vào chương trình

main:           # Nhãn điểm vào bắt đầu thực thi lệnh
    # --------------------------------------------------------------------------
    # BƯỚC 0: Nạp địa chỉ cơ sở của mảng vào thanh ghi $s0
    # Tương đương C: int *s0 = array;
    # --------------------------------------------------------------------------
    la   $s0, array

    # --------------------------------------------------------------------------
    # BƯỚC 1: Đọc và in lần lượt từ phần tử index 9 (offset 36) lùi về index 0 (offset 0)
    # Cú pháp: lw $a0, offset($s0) đọc 4 bytes tại địa chỉ ($s0 + offset) vào $a0
    # --------------------------------------------------------------------------

    # --- Phần tử index 9: array[9] (Offset = 9 * 4 = 36 bytes, giá trị: 10) ---
    lw   $a0, 36($s0)           # Nạp giá trị 10 vào $a0
    li   $v0, 1                 # In số nguyên
    syscall
    li   $v0, 4                 # In chuỗi ", "
    la   $a0, sep
    syscall

    # --- Phần tử index 8: array[8] (Offset = 8 * 4 = 32 bytes, giá trị: 0) ---
    lw   $a0, 32($s0)           # Nạp giá trị 0 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 7: array[7] (Offset = 7 * 4 = 28 bytes, giá trị: 9) ---
    lw   $a0, 28($s0)           # Nạp giá trị 9 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 6: array[6] (Offset = 6 * 4 = 24 bytes, giá trị: 3) ---
    lw   $a0, 24($s0)           # Nạp giá trị 3 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 5: array[5] (Offset = 5 * 4 = 20 bytes, giá trị: 44) ---
    lw   $a0, 20($s0)           # Nạp giá trị 44 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 4: array[4] (Offset = 4 * 4 = 16 bytes, giá trị: 12) ---
    lw   $a0, 16($s0)           # Nạp giá trị 12 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 3: array[3] (Offset = 3 * 4 = 12 bytes, giá trị: 8) ---
    lw   $a0, 12($s0)           # Nạp giá trị 8 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 2: array[2] (Offset = 2 * 4 = 8 bytes, giá trị: 5) ---
    lw   $a0, 8($s0)            # Nạp giá trị 5 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 1: array[1] (Offset = 1 * 4 = 4 bytes, giá trị: 2) ---
    lw   $a0, 4($s0)            # Nạp giá trị 2 vào $a0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall

    # --- Phần tử index 0: array[0] (Offset = 0 * 4 = 0 bytes, giá trị: 1) ---
    # Chú ý: Phần tử cuối cùng in ra không cần in dấu phẩy ", "
    lw   $a0, 0($s0)            # Nạp giá trị 1 vào $a0
    li   $v0, 1
    syscall

    # In ký tự xuống dòng
    li   $v0, 4
    la   $a0, newline
    syscall

    # Thoát chương trình
    li   $v0, 10
    syscall


# ==============================================================================
# PHƯƠNG ÁN 2: DÙNG VÒNG LẶP RẼ NHÁNH CHO MẢNG CÓ KÍCH THƯỚC LỚN (N PHẦN TỬ)
# ==============================================================================
# 1. NGUYÊN LÝ THUẬT TOÁN ĐẢO NGƯỢC BẰNG VÒNG LẶP:
#    - Khi mảng có số lượng phần tử lớn (ví dụ N = 100), kỹ thuật trải mã sẽ làm
#      mã nguồn phình to 100 dòng lệnh. Lúc này, dùng vòng lặp FOR là giải pháp tối ưu.
#    - Khởi tạo biến đếm index i từ phần tử cuối cùng: i = N - 1 = 10 - 1 = 9 ($t0 = 9).
#    - Cơ chế kiểm tra điều kiện lặp:
#         + Điều kiện tiếp tục: Trong khi i >= 0. Lệnh MIPS tương ứng là `bgez $t0, loop_reverse`
#           (bgez = Branch if Greater than or Equal to Zero).
#         + Khi i giảm về -1, điều kiện i >= 0 bị sai -> CPU tự động thoát khỏi vòng lặp.
#    - Cơ chế xử lý dấu phẩy ", ":
#         + Để mảng in ra có định dạng đẹp chuẩn "10, 0, 9, ..., 1", phần tử cuối cùng in ra
#           (ứng với i = 0) không được có dấu phẩy ở đuôi.
#         + Lệnh `beqz $t0, skip_comma` (Branch if Equal to Zero) kiểm tra: nếu i == 0 thì
#           nhảy qua lệnh in chuỗi ", ", sau đó giảm i và kết thúc.
#
# 2. ĐOẠN MÃ MIPS HOÀN CHỈNH CỦA PHƯƠNG ÁN VÒNG LẶP:
# ------------------------------------------------------------------------------
# .text
# main_loop_reverse:
#     la   $s0, array              # $s0 = Địa chỉ cơ sở của mảng
#     li   $t0, 9                  # $t0 = biến đếm index i = 9 (phần tử cuối mảng)
#
# loop_reverse:
#     # Bước 1: Tính địa chỉ phần tử array[i] trong RAM
#     # Offset = i * 4. Dịch trái 2 bit (sll) tương đương nhân 4:
#     sll  $t1, $t0, 2             # $t1 = i * 4 (độ lệch byte của phần tử i)
#     add  $t2, $s0, $t1           # $t2 = Base + Offset = Địa chỉ ô nhớ của array[i]
#
#     # Bước 2: Nạp giá trị từ RAM vào CPU và in ra màn hình
#     lw   $a0, 0($t2)             # $a0 = giá trị phần tử array[i]
#     li   $v0, 1                  # Syscall 1: in số nguyên
#     syscall
#
#     # Bước 3: Kiểm tra định dạng xuất (nếu là phần tử cuối i == 0 thì bỏ qua dấu phẩy)
#     beqz $t0, skip_comma         # Nếu i == 0 -> Nhảy đến nhãn skip_comma
#
#     # Bước 4: In chuỗi phân cách ", " cho các phần tử từ index 9 về index 1
#     li   $v0, 4                  # Syscall 4: in chuỗi
#     la   $a0, sep                # In ", "
#     syscall
#
# skip_comma:
#     # Bước 5: Giảm biến đếm i (i--) và kiểm tra điều kiện lặp
#     addi $t0, $t0, -1            # i = i - 1
#     bgez $t0, loop_reverse       # Nếu i >= 0 thì tiếp tục lặp lại
#
#     # Bước 6: In ký tự xuống dòng và kết thúc chương trình
#     li   $v0, 4
#     la   $a0, newline
#     syscall
#     li   $v0, 10
#     syscall
# ==============================================================================
