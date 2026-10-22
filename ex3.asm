# ==============================================================================
# BÀI 3: TÍNH BIỂU THỨC PHÂN THỨC F (THƯƠNG VÀ SỐ DƯ)
# BẢO VỆ TOÀN DIỆN: BẮT NGOẠI LỆ CHIA CHO 0 VÀ TRÀN SỐ NGUYÊN (ARITHMETIC OVERFLOW)
# ==============================================================================
#
# 1. LIÊN HỆ VỚI NGÔN NGỮ C / C#:
#    - Tương đương trong C:
#         #include <stdio.h>
#         #include <stdlib.h>
#         int main() {
#             int a, b, c, d;
#             printf("Insert a: "); scanf("%d", &a);
#             printf("Insert b: "); scanf("%d", &b);
#             printf("Insert c: "); scanf("%d", &c);
#             printf("Insert d: "); scanf("%d", &d);
#
#             int term1 = a + 10;
#             int term2 = b - d;
#             int term3 = c - (2 * a);
#
#             // BẮT NGOẠI LỆ TRÀN SỐ PHÉP NHÂN (Dùng hàm nội vi kiểm tra tràn số 32-bit)
#             int prod1, num;
#             if (__builtin_mul_overflow(term1, term2, &prod1) ||
#                 __builtin_mul_overflow(prod1, term3, &num)) {
#                 printf("Error: Arithmetic overflow! Value exceeds 32-bit system capability.\n");
#                 return 1;
#             }
#
#             int den = a + b + c;
#             // BẮT NGOẠI LỆ MẪU SỐ BẰNG 0
#             if (den == 0) {
#                 printf("Error: Denominator (a + b + c) equals 0! Division by zero is not allowed.\n");
#                 return 1;
#             }
#
#             int quotient  = num / den;  // Thương
#             int remainder = num % den;  // Số dư
#             printf("F = %d, remainder %d\n", quotient, remainder);
#             return 0;
#         }
#
#    - Tương đương trong C#:
#         try {
#             checked { // Khối checked: Tự động ném OverflowException nếu bất kỳ phép tính nào vượt 32-bit
#                 int num = (a + 10) * (b - d) * (c - 2 * a);
#                 int den = a + b + c;
#                 if (den == 0) throw new DivideByZeroException();
#                 int quotient = num / den;
#                 int remainder = num % den;
#                 Console.WriteLine($"F = {quotient}, remainder {remainder}");
#             }
#         } catch (OverflowException) {
#             Console.WriteLine("Error: Arithmetic overflow! Value exceeds 32-bit system capability.");
#         } catch (DivideByZeroException) {
#             Console.WriteLine("Error: Denominator (a + b + c) equals 0! Division by zero is not allowed.");
#         }
#
# ------------------------------------------------------------------------------
# 2. GIỚI HẠN KIẾN TRÚC VÀ LÝ DO XỬ LÝ TRONG PHẠM VI 32-BIT:
#    a) Giới hạn phần cứng của kiến trúc MIPS32 và công cụ MARS:
#       - Giáo trình môn Kiến trúc máy tính (CO2007) sử dụng tập lệnh MIPS32.
#       - Trình mô phỏng MARS 4.5 là môi trường mô phỏng kiến trúc 32-bit:
#         + Toàn bộ 32 thanh ghi đa năng ($zero -> $ra) có độ rộng 32 bits (4 bytes).
#         + Khối số học ALU, thanh ghi và bus dữ liệu vận hành trên từ nhớ 32-bit.
#
#    b) Về tập lệnh MIPS 64-bit:
#       - Kiến trúc MIPS64 hỗ trợ thanh ghi 64-bit và các lệnh như `dmul`, `ddiv`.
#       - Tuy nhiên MARS 4.5 chỉ hỗ trợ tập lệnh MIPS32. Các lệnh MIPS64 sẽ báo lỗi
#         `Unknown instruction` ở pha hợp dịch.
#
#    c) Về việc mô phỏng phép tính 64-bit bằng phần mềm:
#       - Mặc dù lệnh `mult` của MIPS32 lưu kết quả nhân 64-bit vào cặp thanh ghi HI:LO,
#         nhưng phần cứng MIPS32 không có lệnh chia 64-bit cho 32-bit (lệnh `div` chỉ nhận toán hạng 32-bit).
#       - Để chia số 64-bit cho 32-bit trên CPU 32-bit, cần cài đặt thuật toán chia phần mềm
#         bằng vòng lặp dịch bit, vượt ra ngoài phạm vi yêu cầu của Lab 1.
#       - Do đó, giải pháp phù hợp là cho phép nhập trong miền 32-bit và kiểm tra tràn số
#         ở từng phép tính để thông báo lỗi khi vượt giới hạn biểu diễn của hệ thống.
#
# ------------------------------------------------------------------------------
# 3. CƠ CHẾ BẮT NGOẠI LỆ Ở TỪNG KHÂU:
#    a) Ngoại lệ mẫu số bằng 0 (a + b + c = 0):
#       - Trong phần cứng MIPS, lệnh `div` khi gặp số chia bằng 0 không phát sinh ngắt phần cứng,
#         mà để hai thanh ghi LO, HI nhận giá trị mặc định (trên MARS là 0).
#       - Để tránh lỗi logic (Silent Failure), chương trình dùng lệnh `beqz $t4, error_div_zero`
#         để kiểm tra mẫu số trước khi thực hiện phép chia.
#
#    b) Ngoại lệ tràn số có dấu 32-bit (Signed Arithmetic Overflow) ở Tử số:
#       - Tử số là tích của 3 thừa số: (a + 10) * (b - d) * (c - 2a).
#       - Khi giá trị vượt quá khoảng [-2^31, 2^31 - 1], nếu dùng lệnh giả `mul`, CPU chỉ lấy
#         32 bit thấp khiến bit dấu bị sai lệch và cho ra kết quả âm sai.
#       - Giải pháp kiểm tra tràn số bằng tập lệnh chuẩn MIPS:
#         + Dùng lệnh nhân phần cứng `mult $t0, $t1` (lưu kết quả 64-bit vào HI:LO).
#         + Nạp 32-bit thấp vào $t3 (`mflo $t3`) và 32-bit cao vào $t5 (`mfhi $t5`).
#         + Dùng lệnh dịch phải số học `sra $t6, $t3, 31` để lấy bit dấu của LO phủ kín $t6.
#         + Nếu không tràn số 32-bit, giá trị trong thanh ghi HI phải khớp với $t6 (toàn 0 hoặc toàn 1).
#         + Dùng lệnh `bne $t5, $t6, error_overflow` để rẽ nhánh báo lỗi tràn số khi phát hiện sai khác.
#
# ------------------------------------------------------------------------------
# 4. BỘ VÍ DỤ KIỂM THỬ (TESTCASES) TOÀN DIỆN:
#    - Testcase 1 (Số dương chuẩn):
#         Input: a = 3, b = 4, c = 5, d = 6
#         Tử số = 13 * (-2) * (-1) = 26; Mẫu số = 12
#         Output: "F = 2, remainder 2"
#
#    - Testcase 2 (Số âm, kết quả âm):
#         Input: a = 1, b = 2, c = 3, d = 5
#         Tử số = 11 * (-3) * 1 = -33; Mẫu số = 6
#         Output: "F = -5, remainder -3"
#
#    - Testcase 3 (Ngoại lệ Mẫu số bằng 0):
#         Input: a = 2, b = -2, c = 0, d = 5  =>  Mẫu số = 0
#         Output: "Error: Denominator (a + b + c) equals 0! Division by zero is not allowed."
#
#    - Testcase 4 (Ngoại lệ Mẫu số bằng 0 do 3 số đối xứng):
#         Input: a = 10, b = -5, c = -5, d = 1  =>  Mẫu số = 0
#         Output: "Error: Denominator (a + b + c) equals 0! Division by zero is not allowed."
#
#    - Testcase 5 (Thương bằng 0, số dư dương):
#         Input: a = 0, b = 1, c = 10, d = 0  =>  Tử số = 100, Mẫu số = 11
#         Output: "F = 9, remainder 1"
#
#    - Testcase 6 (Ngoại lệ Tràn số nguyên có dấu 32-bit ở Tử số):
#         Input: a = 20000, b = 30000, c = 50000, d = 0
#         Tử số = 20010 * 30000 * 10000 = 6.003 * 10^12 > 2.147 * 10^9
#         Output: "Error: Arithmetic overflow! Value exceeds 32-bit system capability."
#
# ------------------------------------------------------------------------------
# 5. QUY ƯỚC THANH GHI:
#    - $s0, $s1, $s2, $s3 : Lưu 4 số nguyên đầu vào a, b, c, d
#    - $t0, $t1, $t2      : Lưu 3 thừa số: (a + 10), (b - d), (c - 2*a)
#    - $t3 : Lưu 32-bit thấp của Tử số (lấy từ thanh ghi LO)
#    - $t4 : Lưu giá trị Mẫu số (a + b + c)
#    - $t5 : Lưu 32-bit cao của phép nhân (lấy từ thanh ghi HI) để kiểm tra tràn số
#    - $t6 : Lưu phần mở rộng dấu của LO (`LO >> 31`) để so sánh với HI
#    - $s4 : Lưu Thương số (Quotient)
#    - $s5 : Lưu Số dư (Remainder)
#
# 6. KIẾN THỨC NỀN TẢNG (GIÁO TRÌNH CO2007 - CHƯƠNG 2 & PHỤ LỤC A):
#    - `.data` (Chỉ thị phân vùng dữ liệu, Mục 2.10): Cấp phát bộ nhớ tĩnh cho các chuỗi câu nhắc (0x10010000).
#    - `.text` (Chỉ thị phân vùng mã lệnh, Mục 2.10): Chứa các lệnh máy thực thi (0x00400000).
#    - `.globl main` (Mục 2.10): Khai báo nhãn `main` toàn cục để hệ thống nhận diện điểm vào chương trình.
#    - `main:` (Mục 2.3): Nhãn đánh dấu lệnh khởi đầu thực thi.
# ==============================================================================

.data
    # Phân vùng dữ liệu tĩnh (Static Data Segment)
    prompt_a:       .asciiz "Insert a: "
    prompt_b:       .asciiz "Insert b: "
    prompt_c:       .asciiz "Insert c: "
    prompt_d:       .asciiz "Insert d: "
    msg_f:          .asciiz "F = "
    msg_rem:        .asciiz ", remainder "
    err_div_zero:   .asciiz "Error: Denominator (a + b + c) equals 0! Division by zero is not allowed.\n"
    err_overflow:   .asciiz "Error: Arithmetic overflow! Value exceeds 32-bit system capability.\n"
    newline:        .asciiz "\n"

.text
.globl main     # Khai báo nhãn toàn cục cho điểm vào chương trình

main:           # Nhãn điểm vào bắt đầu thực thi lệnh
    # --------------------------------------------------------------------------
    # BƯỚC 1: Nhập lần lượt 4 số nguyên a, b, c, d từ bàn phím
    # Chấp nhận toàn bộ dải giá trị 32-bit tối đa: [-2147483648, 2147483647]
    # --------------------------------------------------------------------------
    # --- Nhập a ---
    li   $v0, 4
    la   $a0, prompt_a
    syscall
    li   $v0, 5                 # Syscall 5: đọc số nguyên
    syscall
    move $s0, $v0               # $s0 = a

    # --- Nhập b ---
    li   $v0, 4
    la   $a0, prompt_b
    syscall
    li   $v0, 5
    syscall
    move $s1, $v0               # $s1 = b

    # --- Nhập c ---
    li   $v0, 4
    la   $a0, prompt_c
    syscall
    li   $v0, 5
    syscall
    move $s2, $v0               # $s2 = c

    # --- Nhập d ---
    li   $v0, 4
    la   $a0, prompt_d
    syscall
    li   $v0, 5
    syscall
    move $s3, $v0               # $s3 = d

    # --------------------------------------------------------------------------
    # BƯỚC 2: Tính toán 3 thừa số ban đầu
    # --------------------------------------------------------------------------
    # Thừa số 1: (a + 10)
    addi $t0, $s0, 10           # $t0 = a + 10

    # Thừa số 2: (b - d)
    sub  $t1, $s1, $s3           # $t1 = b - d

    # Thừa số 3: (c - 2 * a)
    sll  $t2, $s0, 1             # $t2 = 2 * a (dịch trái 1 bit tương đương nhân 2)
    sub  $t2, $s2, $t2           # $t2 = c - (2 * a)

    # --------------------------------------------------------------------------
    # BƯỚC 3: Nhân tích lũy Tử số CÓ BẮT NGOẠI LỆ TRÀN SỐ 32-BIT Ở TỪNG BƯỚC
    # --------------------------------------------------------------------------

    # --- Lần nhân 1: (a + 10) * (b - d) ---
    mult $t0, $t1                # Nhân 2 số 32-bit -> Kết quả 64-bit lưu vào HI:LO
    mflo $t3                    # $t3 = LO (32-bit thấp)
    mfhi $t5                    # $t5 = HI (32-bit cao)

    # Kiểm tra tràn số: Dịch phải số học 31 bit để lấy bit dấu phủ kín thanh ghi
    sra  $t6, $t3, 31           # Nếu LO dương -> $t6 = 0x00000000; Nếu LO âm -> $t6 = 0xFFFFFFFF
    bne  $t5, $t6, error_overflow   # Nếu HI khác phần mở rộng dấu của LO -> Báo lỗi tràn số ngay!

    # --- Lần nhân 2: Tích trên nhân tiếp với thừa số 3 (c - 2 * a) ---
    mult $t3, $t2                # Nhân tiếp với thừa số 3 -> Lưu 64-bit vào HI:LO
    mflo $t3                    # $t3 = Tử số hoàn chỉnh (32-bit thấp)
    mfhi $t5                    # $t5 = 32-bit cao
    sra  $t6, $t3, 31           # Lấy bit dấu của LO
    bne  $t5, $t6, error_overflow   # Nếu HI khác phần mở rộng dấu -> Báo lỗi tràn số ngay!

    # --------------------------------------------------------------------------
    # BƯỚC 4: Tính Mẫu số = a + b + c và BẮT NGOẠI LỆ CHIA CHO 0
    # --------------------------------------------------------------------------
    add  $t4, $s0, $s1           # $t4 = a + b
    add  $t4, $t4, $s2           # $t4 = (a + b) + c => Mẫu số
    beqz $t4, error_div_zero     # Nếu Mẫu số == 0 -> Nhảy báo lỗi chia cho 0 lập tức!

    # --------------------------------------------------------------------------
    # BƯỚC 5: Thực hiện phép chia an toàn Tử số cho Mẫu số
    # --------------------------------------------------------------------------
    div  $t3, $t4                # Chia Tử số ($t3) cho Mẫu số ($t4)
    mflo $s4                    # Lấy Thương số từ LO
    mfhi $s5                    # Lấy Số dư từ HI

    # --------------------------------------------------------------------------
    # BƯỚC 6: In kết quả ra màn hình: "F = <quotient>, remainder <remainder>"
    # --------------------------------------------------------------------------
    li   $v0, 4
    la   $a0, msg_f
    syscall

    li   $v0, 1
    move $a0, $s4
    syscall

    li   $v0, 4
    la   $a0, msg_rem
    syscall

    li   $v0, 1
    move $a0, $s5
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # Kết thúc chương trình bình thường (Exit code 0)
    li   $v0, 10
    syscall

# ------------------------------------------------------------------------------
# KHỐI XỬ LÝ NGOẠI LỆ 1: MẪU SỐ BẰNG 0
# ------------------------------------------------------------------------------
error_div_zero:
    li   $v0, 4
    la   $a0, err_div_zero      # In "Error: Denominator (a + b + c) equals 0! Division by zero is not allowed.\n"
    syscall

    li   $v0, 10                # Thoát an toàn
    syscall

# ------------------------------------------------------------------------------
# KHỐI XỬ LÝ NGOẠI LỆ 2: TRÀN SỐ NGUYÊN 32-BIT TRONG TÍNH TOÁN
# ------------------------------------------------------------------------------
error_overflow:
    li   $v0, 4
    la   $a0, err_overflow      # In "Error: Arithmetic overflow! Value exceeds 32-bit system capability.\n"
    syscall

    li   $v0, 10                # Thoát an toàn
    syscall
