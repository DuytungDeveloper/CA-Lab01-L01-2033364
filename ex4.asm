# ==============================================================================
# BÀI 4: IN BIỂU DIỄN NHỊ PHÂN CỦA SỐ NGUYÊN N (CÓ BẮT NGOẠI LỆ ĐẦY ĐỦ)
# - CHƯƠNG TRÌNH CHÍNH (THEO ĐỀ BÀI LAB 1): 4-BIT (0 <= N < 16)
# - PHẦN MỞ RỘNG 1: DẢI SỐ CÓ DẤU TỪ -999 ĐẾN 999 (11-BIT BÙ 2, VÒNG LẶP FOR VỚI SRLV)
# - PHẦN MỞ RỘNG 2: DẢI SỐ TỪ 0 ĐẾN VÔ CÙNG / GIỚI HẠN 32-BIT (LEADING ZEROS SUPPRESSION)
# ==============================================================================
#
# 1. LIÊN HỆ VỚI NGÔN NGỮ C / C#:
#    - Tương đương trong C (bản 4-bit):
#         #include <stdio.h>
#         int main() {
#             int n;
#             printf("Please enter a positive integer less than 16: ");
#             scanf("%d", &n);
#
#             // BẮT NGOẠI LỆ: Kiểm tra khoảng giá trị hợp lệ 4-bit (0 <= n <= 15)
#             if (n < 0 || n >= 16) {
#                 printf("Error: Input must be a positive integer less than 16 (0 to 15)!\n");
#                 return 1;
#             }
#
#             printf("Its binary form is: ");
#             printf("%d", (n >> 3) & 1); // Bit 3 (trọng số 2^3 = 8)
#             printf("%d", (n >> 2) & 1); // Bit 2 (trọng số 2^2 = 4)
#             printf("%d", (n >> 1) & 1); // Bit 1 (trọng số 2^1 = 2)
#             printf("%d\n", n & 1);      // Bit 0 (trọng số 2^0 = 1)
#             return 0;
#         }
#
#    - Tương đương trong C#:
#         int n = int.Parse(Console.ReadLine());
#         if (n < 0 || n >= 16) {
#             throw new ArgumentOutOfRangeException("Error: Input must be a positive integer less than 16 (0 to 15)!");
#         }
#         Console.Write("Its binary form is: ");
#         Console.Write((n >> 3) & 1);
#         Console.Write((n >> 2) & 1);
#         Console.Write((n >> 1) & 1);
#         Console.WriteLine(n & 1);
#
# ------------------------------------------------------------------------------
# 2. VÍ DỤ MINH HỌA TỪNG BIT VỚI SỐ CỤ THỂ (SỐ 10 TRONG DẢI 4-BIT):
#    - Số 10 ở hệ thập phân khi đổi sang nhị phân 4-bit b3 b2 b1 b0 là:
#        10 = 1*2^3 + 0*2^2 + 1*2^1 + 0*2^0 = 8 + 0 + 2 + 0 => dạng nhị phân là: 1 0 1 0
#        Trong thanh ghi 32-bit $s0:  [... 0 0 0 0  1 0 1 0]
#                                                   ^ ^ ^ ^
#                                                  b3 b2 b1 b0
#
#    - BƯỚC LẤY BIT 3 (Trọng số 8):
#      + Dịch phải 3 bit: srl $t0, $s0, 3 -> bit b3 nhảy về vị trí bit 0: [... 0 0 0 0  0 0 0 1]
#      + Mặt nạ AND với 1: andi $t0, $t0, 1 -> 1 & 1 = 1.
#      + In bằng Syscall 1 -> màn hình in ra: 1
#
#    - BƯỚC LẤY BIT 2 (Trọng số 4):
#      + Dịch phải 2 bit: srl $t0, $s0, 2 -> bit b2 nhảy về vị trí bit 0: [... 0 0 0 0  0 0 1 0]
#      + Mặt nạ AND với 1: andi $t0, $t0, 1 -> 0 & 1 = 0.
#      + In bằng Syscall 1 -> màn hình in tiếp: 0
#
#    - BƯỚC LẤY BIT 1 (Trọng số 2):
#      + Dịch phải 1 bit: srl $t0, $s0, 1 -> bit b1 nhảy về vị trí bit 0: [... 0 0 0 0  0 1 0 1]
#      + Mặt nạ AND với 1: andi $t0, $t0, 1 -> 1 & 1 = 1.
#      + In bằng Syscall 1 -> màn hình in tiếp: 1
#
#    - BƯỚC LẤY BIT 0 (Trọng số 1):
#      + Lấy trực tiếp: andi $t0, $s0, 1 -> 0 & 1 = 0.
#      + In bằng Syscall 1 -> màn hình in tiếp: 0
#    => Màn hình in ra chuỗi kết quả: "1010"!
#
# ------------------------------------------------------------------------------
# 3. PHẦN MỞ RỘNG 1: DẢI GIÁ TRỊ TỪ -999 ĐẾN 999 (SỐ CÓ DẤU, BIỂU DIỄN 11-BIT BÙ 2):
#    a) Bản chất số âm trong phần cứng (Mã bù 2 - Two's Complement):
#       - CPU máy tính không lưu ký tự "-" trong chuỗi nhị phân. Mọi số nguyên có dấu
#         đều được mã hóa dưới dạng bù 2:
#            Số âm = Đảo toàn bộ các bit của số dương tương ứng rồi cộng thêm 1.
#       - Bit ngoài cùng bên trái (MSB) luôn là bit dấu:
#            MSB = 0: số dương hoặc 0.
#            MSB = 1: số âm.
#
#    b) Tại sao dải [-999, 999] cần tối thiểu 11 bit?
#       - Với n bit có dấu (bù 2), miền giá trị biểu diễn được là: [-2^(n-1), 2^(n-1) - 1]
#       - Xét n = 10 bit: Miền giá trị = [-2^9, 2^9 - 1] = [-512, 511]  -> KHÔNG ĐỦ chứa 999 và -999!
#       - Xét n = 11 bit: Miền giá trị = [-2^10, 2^10 - 1] = [-1024, 1023] -> VỪA ĐỦ chứa trọn vẹn [-999, 999]!
#       - Do đó, cần vòng lặp 11 bước, chạy từ bit thứ 10 (MSB) lùi về bit 0 (LSB).
#
#    c) Ví dụ so sánh giá trị nhị phân giữa +999 và -999:
#       - +999:  011 1110 0111  (bit 10 là 0)
#       - -999:  100 0001 1001  (bit 10 là 1; tính bằng cách đảo bit của 999: 100 0001 1000 rồi + 1)
#
#    d) Kiến trúc lệnh MIPS: Tại sao dùng `srlv` thay vì `srl`?
#       - Lệnh `srl` (Shift Right Logical) chỉ chấp nhận độ dời là hằng số trực tiếp cố định (shamt: 0-31).
#       - Khi đưa vào vòng lặp FOR với biến đếm $t1 (i = 10 xuống 0) lưu trong thanh ghi,
#         MIPS bắt buộc phải dùng lệnh `srlv` (Shift Right Logical Variable):
#             Cú pháp: srlv rd, rt, rs  =>  rd = rt >> rs
#
# ------------------------------------------------------------------------------
# 4. PHẦN MỞ RỘNG 2: DẢI GIÁ TRỊ TỪ 0 ĐẾN VÔ CÙNG ([0, +vô cùng)):
#    a) Giới hạn vật lý của kiến trúc phần cứng 32-bit:
#       - Trong máy tính số, không tồn tại khái niệm "vô hạn" thực tế vì bộ nhớ và thanh ghi
#         luôn có kích thước vật lý hữu hạn (thanh ghi MIPS có độ rộng đúng 32 bit).
#       - Cận dưới: N >= 0 (chặn ngoại lệ số âm bằng lệnh `bltz $s0, error_negative`).
#       - Cận trên thực tế của kiểu số nguyên 32-bit có dấu (Signed Integer):
#            N_max = 2^31 - 1 = 2,147,483,647 (0x7FFFFFFF).
#            Nếu vượt quá giá trị này, hiện tượng Tràn số có dấu (Signed Overflow) xảy ra:
#            bit thứ 31 (MSB) bị bật thành 1, khiến CPU diễn giải thành số âm!
#            (Nếu coi là số không dấu Unsigned: N_max = 2^32 - 1 = 4,294,967,295).
#
#    b) Hai phương pháp hiển thị chuỗi nhị phân cho trường hợp [0, +vô cùng):
#       - Phương pháp 2A (In cố định 32-bit thanh ghi):
#            Chạy vòng lặp từ bit 31 về bit 0 (in đủ toàn bộ 32 bit trong thanh ghi CPU).
#            Ví dụ với số 10: 00000000000000000000000000001010
#       - Phương pháp 2B (In linh hoạt - Bỏ qua số 0 vô nghĩa ở đầu / Leading Zeros Suppression):
#            Dùng cờ hiệu (flag $t2) để tìm bit 1 đầu tiên rồi mới bắt đầu in.
#            Giúp kết quả hiển thị tự nhiên như cách viết toán học thông thường.
#            Ví dụ với số 10: 1010
#            Riêng trường hợp N = 0: in trực tiếp một ký số '0'.
#
# ------------------------------------------------------------------------------
# 5. QUY ƯỚC THANH GHI:
#    - $s0 : Lưu giá trị số nguyên n người dùng nhập vào
#    - $t0 : Chứa giá trị của từng bit sau khi trích xuất (0 hoặc 1)
#    - $t1 : Biến đếm vòng lặp (chỉ số bit i)
#    - $t2 : Cờ hiệu đánh dấu bit có nghĩa đầu tiên (trong kỹ thuật Leading Zeros)
#    - $t8, $t9 : Thanh ghi chứa các ngưỡng cận dưới/cận trên kiểm tra ngoại lệ
#    - $a0 : Tham số truyền vào syscall (in chuỗi hoặc in số)
#
# 6. KIẾN THỨC NỀN TẢNG (GIÁO TRÌNH CO2007 - CHƯƠNG 2 & PHỤ LỤC A):
#    - `.data` (Chỉ thị phân vùng dữ liệu, Mục 2.10): Khai báo vùng nhớ chứa các chuỗi câu nhắc (0x10010000).
#    - `.text` (Chỉ thị phân vùng mã lệnh, Mục 2.10): Chứa các lệnh máy thực thi (0x00400000).
#    - `.globl main` (Mục 2.10): Khai báo nhãn toàn cục cho điểm vào chương trình.
#    - `main:` (Mục 2.3): Nhãn đánh dấu lệnh khởi đầu thực thi.
# ==============================================================================

.data
    # Phân vùng dữ liệu tĩnh (Static Data Segment)
    prompt:     .asciiz "Please enter a positive integer less than 16: "
    msg_result: .asciiz "Its binary form is: "
    err_range:  .asciiz "Error: Input must be a positive integer less than 16 (0 to 15)!\n"
    newline:    .asciiz "\n"

.text
.globl main     # Khai báo nhãn toàn cục cho điểm vào chương trình

main:           # Nhãn điểm vào bắt đầu thực thi lệnh
    # --------------------------------------------------------------------------
    # BƯỚC 1: Nhập số nguyên N từ bàn phím
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, prompt
    syscall

    li   $v0, 5                 # Syscall 5: đọc số nguyên
    syscall
    move $s0, $v0               # $s0 = n

    # --------------------------------------------------------------------------
    # BƯỚC 2: BẮT NGOẠI LỆ - Kiểm tra khoảng giá trị (0 <= N <= 15)
    # Tương đương C#: if (n < 0 || n >= 16) throw new ArgumentOutOfRangeException(...);
    # --------------------------------------------------------------------------
    bltz $s0, error_range       # Nếu n < 0 -> Báo lỗi ngoài khoảng
    li   $t9, 15
    bgt  $s0, $t9, error_range  # Nếu n > 15 -> Báo lỗi ngoài khoảng

    # --------------------------------------------------------------------------
    # BƯỚC 3: In tiêu đề kết quả: "Its binary form is: "
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, msg_result
    syscall

    # --------------------------------------------------------------------------
    # BƯỚC 4: Trích xuất và in tuần tự 4 bit từ trái sang phải (b3 -> b2 -> b1 -> b0)
    # --------------------------------------------------------------------------

    # --- Trích xuất và in Bit 3 (Trọng số 2^3 = 8, MSB) ---
    srl  $t0, $s0, 3            # Dịch phải 3 bit ($s0 >> 3), đưa bit 3 về vị trí bit 0
    andi $t0, $t0, 1            # Giữ lại bit cuối cùng ($t0 & 1)
    li   $v0, 1                 # Syscall 1: in số nguyên
    move $a0, $t0
    syscall

    # --- Trích xuất và in Bit 2 (Trọng số 2^2 = 4) ---
    srl  $t0, $s0, 2            # Dịch phải 2 bit ($s0 >> 2)
    andi $t0, $t0, 1            # Giữ lại bit cuối
    li   $v0, 1
    move $a0, $t0
    syscall

    # --- Trích xuất và in Bit 1 (Trọng số 2^1 = 2) ---
    srl  $t0, $s0, 1            # Dịch phải 1 bit ($s0 >> 1)
    andi $t0, $t0, 1            # Giữ lại bit cuối
    li   $v0, 1
    move $a0, $t0
    syscall

    # --- Trích xuất và in Bit 0 (Trọng số 2^0 = 1, LSB) ---
    andi $t0, $s0, 1            # Không cần dịch, lấy trực tiếp bit tận cùng bên phải
    li   $v0, 1
    move $a0, $t0
    syscall

    # --------------------------------------------------------------------------
    # BƯỚC 5: In ký tự xuống dòng và kết thúc bình thường
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, newline
    syscall

    li   $v0, 10
    syscall

# ------------------------------------------------------------------------------
# XỬ LÝ NGOẠI LỆ CHƯƠNG TRÌNH CHÍNH: In thông báo lỗi khi n < 0 hoặc n >= 16
# ------------------------------------------------------------------------------
error_range:
    li   $v0, 4
    la   $a0, err_range
    syscall

    li   $v0, 10                # Thoát an toàn
    syscall


# ==============================================================================
# PHẦN ĐÍNH KÈM: MÃ NGUỒN MẪU HOÀN CHỈNH CHO CÁC TRƯỜNG HỢP MỞ RỘNG
# ==============================================================================
#
# ------------------------------------------------------------------------------
# CODE MẪU MỞ RỘNG 1: DẢI [-999, 999] (11-BIT BÙ 2 DÙNG VÒNG LẶP FOR VỚI SRLV)
# ------------------------------------------------------------------------------
# .data
#     p_ext1:    .asciiz "Nhap so nguyen N trong khoang [-999, 999]: "
#     res_ext1:  .asciiz "Dang nhi phan 11-bit bu 2 la: "
#     err_ext1:  .asciiz "Loi: So phai nam trong khoang [-999, 999]!\n"
#     nl_ext1:   .asciiz "\n"
#
# .text
# main_ext1:
#     # 1. Nhập N
#     li   $v0, 4; la $a0, p_ext1; syscall
#     li   $v0, 5; syscall
#     move $s0, $v0
#
#     # 2. Bắt ngoại lệ hai đầu [-999, 999]
#     li   $t8, -999
#     blt  $s0, $t8, err_label_ext1   # Nếu N < -999 -> Báo lỗi
#     li   $t9, 999
#     bgt  $s0, $t9, err_label_ext1   # Nếu N > 999  -> Báo lỗi
#
#     # 3. In tiêu đề
#     li   $v0, 4; la $a0, res_ext1; syscall
#
#     # 4. Vòng lặp FOR từ bit 10 về bit 0 (11 bit)
#     li   $t1, 10                    # Biến đếm i = 10 (MSB)
# loop_ext1:
#     srlv $t0, $s0, $t1              # Dịch phải theo biến: $t0 = $s0 >> $t1
#     andi $t0, $t0, 1                # Giữ lại bit tận cùng
#     li   $v0, 1; move $a0, $t0; syscall  # In bit ra màn hình
#     addi $t1, $t1, -1               # i--
#     bgez $t1, loop_ext1             # Lặp tiếp khi i >= 0
#
#     # 5. Xuống dòng và kết thúc
#     li   $v0, 4; la $a0, nl_ext1; syscall
#     li   $v0, 10; syscall
#
# err_label_ext1:
#     li   $v0, 4; la $a0, err_ext1; syscall
#     li   $v0, 10; syscall
#
# ------------------------------------------------------------------------------
# CODE MẪU MỞ RỘNG 2: DẢI [0, +VÔ CÙNG / GIỚI HẠN 32-BIT] (LOẠI BỎ SỐ 0 VÔ NGHĨA)
# ------------------------------------------------------------------------------
# .data
#     p_ext2:    .asciiz "Nhap so nguyen khong am N (0 <= N <= 2147483647): "
#     res_ext2:  .asciiz "Dang nhi phan rut gon la: "
#     err_ext2:  .asciiz "Loi: So nhap vao phai la so khong am (N >= 0)!\n"
#     nl_ext2:   .asciiz "\n"
#
# .text
# main_ext2:
#     # 1. Nhập N
#     li   $v0, 4; la $a0, p_ext2; syscall
#     li   $v0, 5; syscall
#     move $s0, $v0
#
#     # 2. Bắt ngoại lệ số âm (N < 0)
#     bltz $s0, err_label_ext2       # Nếu N < 0 -> Báo lỗi
#
#     # 3. In tiêu đề
#     li   $v0, 4; la $a0, res_ext2; syscall
#
#     # 4. Trường hợp đặc biệt nếu N = 0 -> in trực tiếp ký số 0
#     bnez $s0, start_suppression
#     li   $v0, 1; li $a0, 0; syscall
#     j    exit_ext2
#
# start_suppression:
#     # 5. Vòng lặp duyệt 32 bit từ 31 về 0 với cờ hiệu $t2 loại bỏ leading zeros
#     li   $t1, 31                    # Biến đếm i = 31 (MSB của từ nhớ 32-bit)
#     li   $t2, 0                     # Cờ hiệu flag: 0 = chưa in bit có nghĩa nào, 1 = đã bắt đầu in
#
# loop_ext2:
#     srlv $t0, $s0, $t1              # Trích xuất bit thứ i: $t0 = $s0 >> $t1
#     andi $t0, $t0, 1
#     bnez $t2, print_current_bit    # Nếu cờ đã bật (đã gặp bit 1 trước đó) -> In luôn
#     beqz $t0, skip_leading_zero    # Nếu cờ chưa bật và bit hiện tại = 0 -> Bỏ qua
#     li   $t2, 1                     # Gặp bit 1 đầu tiên -> Bật cờ!
#
# print_current_bit:
#     li   $v0, 1; move $a0, $t0; syscall
#
# skip_leading_zero:
#     addi $t1, $t1, -1               # i--
#     bgez $t1, loop_ext2
#
# exit_ext2:
#     li   $v0, 4; la $a0, nl_ext2; syscall
#     li   $v0, 10; syscall
#
# err_label_ext2:
#     li   $v0, 4; la $a0, err_ext2; syscall
#     li   $v0, 10; syscall
# ==============================================================================
