# ==============================================================================
# BÀI 2: NHẬP MẢNG 5 PHẦN TỬ VÀ TRUY XUẤT THEO CHỈ SỐ (CÓ BẮT NGOẠI LỆ ĐẦY ĐỦ)
# ==============================================================================
#
# PHÂN BỔ KIẾN TRÚC MÃ NGUỒN TRONG FILE NÀY:
# 1. PHƯƠNG ÁN CHÍNH NỘP BÀI (MAIN EXECUTION):
#    - Tuân thủ nguyên tắc cốt lõi của Lab 1: Chỉ sử dụng các lệnh tuần tự,
#      các lệnh số học (arithmetic) và nạp/lưu dữ liệu (data transfer).
#    - Áp dụng kỹ thuật Trải mã tuần tự (Loop Unrolling): Nhập trực tiếp 5 phần tử
#      vào RAM thông qua các độ lệch byte cố định (Offset 0, 4, 8, 12, 16).
#    - Lệnh rẽ nhánh (bltz, bgt) CHỈ dùng để bắt ngoại lệ bảo vệ bộ nhớ (an toàn runtime).
#
# 2. PHƯƠNG ÁN THAM KHẢO MỞ RỘNG (ĐÍNH KÈM Ở CUỐI FILE):
#    - Sử dụng cấu trúc vòng lặp FOR với các lệnh rẽ nhánh (bge, j, addi) để minh họa
#      cách mở rộng khi kích thước mảng tăng lên N phần tử bất kỳ.
#    - Từng dòng lệnh được giải thích chi tiết cặn kẽ để dễ dàng đối chiếu.
#
# ==============================================================================
# I. LIÊN HỆ VỚI NGÔN NGỮ BẬC CAO (C / C#):
# ==============================================================================
#
# 1. Mã nguồn tương đương trong C:
#    #include <stdio.h>
#    int main() {
#        int array[5];
#        // Nhập tuần tự từng phần tử:
#        printf("Please input element 0: "); scanf("%d", &array[0]);
#        printf("Please input element 1: "); scanf("%d", &array[1]);
#        printf("Please input element 2: "); scanf("%d", &array[2]);
#        printf("Please input element 3: "); scanf("%d", &array[3]);
#        printf("Please input element 4: "); scanf("%d", &array[4]);
#
#        // Nhập chỉ số tra cứu và kiểm tra ranh giới mảng:
#        int index;
#        printf("Please enter index: ");
#        scanf("%d", &index);
#        if (index < 0 || index > 4) {
#            printf("Error: Index out of bounds (must be between 0 and 4)!\n");
#            return 1;
#        }
#
#        // Bản chất array[index] là số học con trỏ: *(array + index)
#        printf("%d\n", array[index]);
#        return 0;
#    }
#
# 2. Mã nguồn tương đương trong C#:
#    int[] array = new int[5];
#    for (int i = 0; i < 5; i++) {
#        Console.Write($"Please input element {i}: ");
#        array[i] = int.Parse(Console.ReadLine());
#    }
#    Console.Write("Please enter index: ");
#    int index = int.Parse(Console.ReadLine());
#    if (index < 0 || index >= array.Length) {
#        throw new IndexOutOfRangeException("Error: Index out of bounds (must be between 0 and 4)!");
#    }
#    Console.WriteLine(array[index]);
#
# ==============================================================================
# II. CƠ SỞ LÝ THUYẾT KIẾN TRÚC MÁY TÍNH: TẠI SAO OFFSET LÀ 0, 4, 8, 12, 16,...?
# ==============================================================================
#
# 1. Nguyên lý Định địa chỉ theo từng Byte (Byte Addressing):
#    - Trong kiến trúc MIPS, đơn vị nhỏ nhất có thể định địa chỉ riêng biệt trên RAM là 1 BYTE (8 bits).
#    - Mỗi ô nhớ vật lý trên thanh RAM chỉ chứa 1 Byte dữ liệu và được gán một số nguyên duy nhất làm địa chỉ.
#
# 2. Độ rộng của kiểu dữ liệu Từ nhớ (Word - 32 bit):
#    - Kiểu số nguyên trong MIPS (chỉ thị .word hoặc kiểu int trong C/C#) có kích thước 32 bit.
#    - 32 bit = 4 Bytes (vì 32 chia cho 8 bằng 4).
#    - Do đó, để lưu trữ trọn vẹn 1 giá trị số nguyên, CPU bắt buộc phải cấp phát một dãy gồm
#      4 BYTES liên tiếp nhau trong bộ nhớ RAM!
#
# 3. Sơ đồ phân bổ bộ nhớ RAM chi tiết cho mảng 5 phần tử:
#    Giả sử địa chỉ cơ sở của mảng (Base Address) lưu trong $s0 là 0x10010000:
#    +---------------+-----------+-----------------------------------+-----------------------+
#    | Phần tử logic | Kích thước| Các ô nhớ Byte chiếm dụng trên RAM| Địa chỉ bắt đầu       |
#    +---------------+-----------+-----------------------------------+-----------------------+
#    | array[0]      | 4 bytes   | 0x10010000, 0x10010001, 02, 03    | Base + 0  (Offset=0)  |
#    | array[1]      | 4 bytes   | 0x10010004, 0x10010005, 06, 07    | Base + 4  (Offset=4)  |
#    | array[2]      | 4 bytes   | 0x10010008, 0x10010009, 0A, 0B    | Base + 8  (Offset=8)  |
#    | array[3]      | 4 bytes   | 0x1001000C, 0x1001000D, 0E, 0F    | Base + 12 (Offset=12) |
#    | array[4]      | 4 bytes   | 0x10010010, 0x10010011, 12, 13    | Base + 16 (Offset=16) |
#    +---------------+-----------+-----------------------------------+-----------------------+
#    => CÔNG THỨC TỔNG QUÁT:
#          Địa chỉ hiệu dụng (Effective Address) = Địa chỉ cơ sở (Base) + Offset
#          Trong đó: Độ lệch byte (Offset) = Chỉ số phần tử (index) * 4.
#
# 4. Quy tắc Căn chỉnh ranh giới từ nhớ (Word Alignment - Chỉ thị `.align 2`):
#    - Phần cứng MIPS yêu cầu mọi địa chỉ dùng để nạp/lưu Word (lệnh lw, sw) bắt buộc phải là
#      bội số của 4 (tức là 2 bit nhị phân cuối cùng của địa chỉ luôn phải bằng 00).
#    - Nếu địa chỉ là số lẻ (ví dụ 0x10010001), mạch giải mã địa chỉ của CPU sẽ phát sinh ngoại lệ
#      ngắt phần cứng (Alignment Trap Exception): "store address not aligned on word boundary".
#    - Chỉ thị `.align 2` ra lệnh cho trình dịch ép địa chỉ bắt đầu của biến tiếp theo phải chia hết
#      cho 2^2 = 4 bytes, loại bỏ triệt để lỗi căn lề bộ nhớ.
#
# ==============================================================================
# III. PHÂN TÍCH NGOẠI LỆ: NẾU NGƯỜI DÙNG NHẬP SỐ LỚN HƠN 32-BIT THÌ SAO?
# ==============================================================================
#
# 1. Trường hợp người dùng nhập giá trị phần tử mảng (element 0..4) lớn hơn 32-bit:
#    - Ví dụ: Người dùng nhập số 5 tỷ (`5000000000`), `9999999999999999`, hoặc chuỗi chữ `abc`.
#    - Cơ chế bắt lỗi: Lệnh `syscall 5` (`read_int`) được thực thi bởi tầng Kernel của MARS (dựa trên
#      hàm Integer.parseInt trong Java). Khi phát hiện chuỗi nhập vượt quá dải số nguyên 32-bit có dấu
#      [-2^31, 2^31 - 1] = [-2,147,483,648 đến +2,147,483,647], MARS sẽ TỰ ĐỘNG CHẶN ĐỨNG NGAY TẠI BÀN PHÍM
#      và kích hoạt ngắt ngoại lệ:
#          "Runtime exception: invalid integer input (syscall 5)"
#          "Processing terminated due to errors."
#    - Chương trình lập tức dừng lại một cách an toàn. Giá trị vượt ngưỡng không bao giờ có cơ hội lọt
#      vào thanh ghi $v0 hay ghi đè làm hỏng bộ nhớ RAM.
#
# 2. Về việc lưu trữ giá trị phần tử trong RAM:
#    - Khác với Bài 3 (thực hiện phép nhân dồn 3 thừa số sinh ra số hàng nghìn tỷ gây tràn số tính toán),
#      ở Bài 2, sau khi nhận các số 32-bit từ `syscall 5`, chương trình chỉ ghi thẳng vào ô nhớ bằng lệnh
#      `sw $v0, offset($s0)` và sau đó đọc ra bằng `lw $a0, offset($s0)` để in lại.
#    - Vì chương trình HOÀN TOÀN KHÔNG THỰC HIỆN PHÉP TÍNH NHÂN/CHIA NÀO trên các phần tử mảng,
#      nên không thể xảy ra hiện tượng tràn số trong quá trình tính toán.
#
# 3. Trường hợp người dùng nhập chỉ số `index` cần tra cứu:
#    - Nếu nhập index lớn hơn 32-bit: `syscall 5` sẽ tự động chặn đứng ngay từ đầu (`invalid integer input`).
#    - Nếu nhập index là số 32-bit bất kỳ nhưng nằm ngoài khoảng [0, 4] (ví dụ: index âm hoặc index > 4):
#      Mã nguồn chương trình chủ động chặn lại bằng 2 lệnh rẽ nhánh:
#         `bltz $v0, error_index`  (chặn số âm: index < 0)
#         `bgt  $v0, $t9, error_index` (chặn vượt ngưỡng: index > 4)
#      và in ra thông báo lỗi: "Error: Index out of bounds (must be between 0 and 4)!".
#    - Nhờ kiểm tra chặn trước khi tính toán, phép dịch trái `sll $t0, $v0, 2` (nhân 4) chỉ nhận giá trị
#      tối đa là 4 * 4 = 16 bytes, không gây tràn số khi tính toán địa chỉ bộ nhớ.
#
# ==============================================================================
# IV. BẢNG QUY ƯỚC THANH GHI (REGISTER CONVENTION):
# ==============================================================================
#    - $s0 : Lưu địa chỉ cơ sở (Base Address) của mảng array trong bộ nhớ RAM
#    - $t0 : Biến tạm lưu độ lệch byte (Offset = index * 4) tính được từ lệnh dịch bit
#    - $t1 : Biến tạm lưu địa chỉ ô nhớ tuyệt đối của phần tử array[index] trong RAM
#    - $t9 : Thanh ghi tạm chứa cận trên của mảng (hằng số 4) để so sánh ngoại lệ
#    - $v0 : Nhận mã chức năng Syscall từ người lập trình và nhận giá trị trả về từ hệ thống
#    - $a0 : Chứa tham số truyền vào Syscall (địa chỉ chuỗi cần in hoặc số nguyên cần in)
#
# V. KIẾN THỨC NỀN TẢNG (GIÁO TRÌNH CO2007 - CHƯƠNG 2 & PHỤ LỤC A):
#    - `.data` (Chỉ thị trình dịch - Assembler Directive, Mục 2.10 & Phụ lục A):
#         Khai báo phân vùng dữ liệu tĩnh (Static Data Segment, địa chỉ 0x10010000).
#         Dùng để cấp phát vùng nhớ RAM cho mảng và các chuỗi thông báo.
#    - `.text` (Chỉ thị trình dịch - Assembler Directive, Mục 2.10 & Phụ lục A):
#         Khai báo phân vùng chứa mã máy nhị phân 32-bit (Text Segment, địa chỉ 0x00400000).
#    - `.globl main` (Khai báo ký hiệu toàn cục, Mục 2.10):
#         Xuất nhãn `main` ra phạm vi toàn cục để Linker/Loader xác định Entry Point của chương trình.
#    - `main:` (Nhãn điểm vào, Mục 2.3 & Phụ lục A):
#         Đánh dấu vị trí lệnh đầu tiên được CPU nạp vào thực thi.
#    - `0($s0)`, `4($s0)`, `0($t1)` (Định địa chỉ cơ sở - Base Addressing Mode, Mục 2.5):
#         Cú pháp `offset(base_register)`. Địa chỉ ô nhớ hiệu dụng = Base + Offset.
# ==============================================================================

.data
    # Phân vùng dữ liệu tĩnh (Static Data Segment)
    prompt0:    .asciiz "Please input element 0: "
    prompt1:    .asciiz "Please input element 1: "
    prompt2:    .asciiz "Please input element 2: "
    prompt3:    .asciiz "Please input element 3: "
    prompt4:    .asciiz "Please input element 4: "
    prompt_idx: .asciiz "Please enter index: "
    err_index:  .asciiz "Error: Index out of bounds (must be between 0 and 4)!\n"
    newline:    .asciiz "\n"

    # Chỉ thị .align 2: Căn chỉnh bộ nhớ theo bội số của 4 bytes (Word Alignment)
    # Ngăn ngừa lỗi phần cứng: "store address not aligned on word boundary"
    .align 2

    # Chỉ thị .space 20: Cấp phát một vùng nhớ liên tục gồm 20 bytes trên RAM
    # Công thức: 5 phần tử * 4 bytes/phần tử = 20 bytes
    array:      .space 20

.text
.globl main     # Khai báo nhãn toàn cục cho điểm vào chương trình

main:           # Nhãn điểm vào bắt đầu thực thi lệnh
    # --------------------------------------------------------------------------
    # BƯỚC 0: NẠP ĐỊA CHỈ CƠ SỞ CỦA MẢNG VÀO THANH GHI $s0
    # --------------------------------------------------------------------------
    # Lệnh `la` (Load Address) lấy địa chỉ ô nhớ đầu tiên của nhãn `array` nạp vào $s0.
    # Tương đương trong C: int *s0 = array; (hoặc int *s0 = &array[0];)
    la   $s0, array

    # --------------------------------------------------------------------------
    # BƯỚC 1: NHẬP TUẦN TỰ 5 PHẦN TỬ (TRẢI MÃ TUẦN TỰ - LOOP UNROLLING)
    # Tuân thủ tiêu chí Lab 1: Chỉ dùng các lệnh số học và truyền dữ liệu cơ bản.
    # --------------------------------------------------------------------------

    # --- NHẬP PHẦN TỬ 0: array[0] (Độ lệch Offset = 0 * 4 = 0 bytes) ---
    li   $v0, 4                 # Syscall 4: Dịch vụ in chuỗi ký tự (print_string)
    la   $a0, prompt0           # Nạp địa chỉ chuỗi "Please input element 0: " vào $a0
    syscall                     # Thực hiện in chuỗi ra màn hình console

    li   $v0, 5                 # Syscall 5: Dịch vụ đọc số nguyên từ bàn phím (read_int)
    syscall                     # Dừng đợi người dùng nhập số nguyên, kết quả trả về trong $v0
    sw   $v0, 0($s0)            # Store Word: Ghi 4 bytes từ $v0 vào ô nhớ RAM tại ($s0 + 0)
                                # Giải thích: Offset = 0 vì phần tử 0 chiếm 4 byte đầu (Base + 0)

    # --- NHẬP PHẦN TỬ 1: array[1] (Độ lệch Offset = 1 * 4 = 4 bytes) ---
    li   $v0, 4                 # Syscall 4: In chuỗi
    la   $a0, prompt1           # Nạp địa chỉ chuỗi "Please input element 1: " vào $a0
    syscall

    li   $v0, 5                 # Syscall 5: Đọc số nguyên
    syscall
    sw   $v0, 4($s0)            # Store Word: Ghi 4 bytes từ $v0 vào ô nhớ RAM tại ($s0 + 4)
                                # Giải thích: Offset = 4 vì phần tử 0 đã chiếm 4 bytes (0, 1, 2, 3),
                                # nên phần tử 1 bắt đầu tại byte thứ 4 của mảng (Base + 4)

    # --- NHẬP PHẦN TỬ 2: array[2] (Độ lệch Offset = 2 * 4 = 8 bytes) ---
    li   $v0, 4                 # Syscall 4: In chuỗi
    la   $a0, prompt2           # Nạp địa chỉ chuỗi "Please input element 2: " vào $a0
    syscall

    li   $v0, 5                 # Syscall 5: Đọc số nguyên
    syscall
    sw   $v0, 8($s0)            # Store Word: Ghi 4 bytes từ $v0 vào ô nhớ RAM tại ($s0 + 8)
                                # Giải thích: Offset = 2 * 4 = 8 bytes (chiếm các byte 8, 9, 10, 11)

    # --- NHẬP PHẦN TỬ 3: array[3] (Độ lệch Offset = 3 * 4 = 12 bytes) ---
    li   $v0, 4                 # Syscall 4: In chuỗi
    la   $a0, prompt3           # Nạp địa chỉ chuỗi "Please input element 3: " vào $a0
    syscall

    li   $v0, 5                 # Syscall 5: Đọc số nguyên
    syscall
    sw   $v0, 12($s0)           # Store Word: Ghi 4 bytes từ $v0 vào ô nhớ RAM tại ($s0 + 12)
                                # Giải thích: Offset = 3 * 4 = 12 bytes (chiếm các byte 12, 13, 14, 15)

    # --- NHẬP PHẦN TỬ 4: array[4] (Độ lệch Offset = 4 * 4 = 16 bytes) ---
    li   $v0, 4                 # Syscall 4: In chuỗi
    la   $a0, prompt4           # Nạp địa chỉ chuỗi "Please input element 4: " vào $a0
    syscall

    li   $v0, 5                 # Syscall 5: Đọc số nguyên
    syscall
    sw   $v0, 16($s0)           # Store Word: Ghi 4 bytes từ $v0 vào ô nhớ RAM tại ($s0 + 16)
                                # Giải thích: Offset = 4 * 4 = 16 bytes (chiếm các byte 16, 17, 18, 19)

    # --------------------------------------------------------------------------
    # BƯỚC 2: NHẬP CHỈ SỐ INDEX CẦN TRA CỨU TỪ BÀN PHÍM
    # Tương đương C#: int index = int.Parse(Console.ReadLine());
    # --------------------------------------------------------------------------
    li   $v0, 4                 # Syscall 4: In chuỗi câu nhắc
    la   $a0, prompt_idx        # Nạp địa chỉ chuỗi "Please enter index: " vào $a0
    syscall

    li   $v0, 5                 # Syscall 5: Đọc số nguyên index từ bàn phím
    syscall                     # Sau lệnh này, giá trị index người dùng nhập được lưu trong $v0

    # --------------------------------------------------------------------------
    # BƯỚC 3: BẮT NGOẠI LỆ - KIỂM TRA CHỈ SỐ MẢNG CÓ NẰM TRONG KHOẢNG [0, 4]
    # Tương đương C#: if (index < 0 || index > 4) throw new IndexOutOfRangeException(...);
    # --------------------------------------------------------------------------
    # Kiểm tra cận dưới: index < 0
    bltz $v0, error_index       # bltz = Branch if Less Than Zero:
                                # Nếu giá trị trong $v0 < 0 (chỉ số âm), lập tức nhảy đến nhãn
                                # `error_index` để báo lỗi, ngăn chặn đọc ô nhớ ngoài tầm kiểm soát.

    # Kiểm tra cận trên: index > 4
    li   $t9, 4                 # Nạp cận trên hợp lệ của mảng 5 phần tử ($t9 = 5 - 1 = 4)
    bgt  $v0, $t9, error_index  # bgt = Branch if Greater Than:
                                # Nếu $v0 > $t9 (tức index > 4), nhảy ngay đến nhãn `error_index`
                                # để ngăn chặn đọc ô nhớ rác nằm ngoài 20 bytes đã cấp phát.

    # --------------------------------------------------------------------------
    # BƯỚC 4: TÍNH ĐỊA CHỈ Ô NHỚ BẰNG SỐ HỌC CON TRỎ TRONG THỜI GIAN O(1)
    # Tương đương C: int *ptr = array + index; (truy xuất địa chỉ &array[index])
    # --------------------------------------------------------------------------
    # Phép tính cần thực hiện: Offset = index * 4
    # Trong MIPS, thay vì dùng lệnh nhân `mul` (tốn nhiều chu kỳ xung nhịp ALU), ta dùng
    # lệnh dịch trái logic 2 bit `sll` (Shift Left Logical).
    # Vì mỗi lần dịch trái 1 bit là nhân 2, nên dịch trái 2 bit tương đương nhân với 2^2 = 4.
    # Mạch Barrel Shifter của MIPS thực thi lệnh `sll` chỉ trong đúng 1 CHU KỲ XUNG NHỊP!
    sll  $t0, $v0, 2            # $t0 = $v0 << 2 = index * 4 (Độ lệch byte Offset trong RAM)

    # Tính địa chỉ ô nhớ tuyệt đối:
    # Địa chỉ ô nhớ hiệu dụng = Địa chỉ cơ sở mảng ($s0) + Độ lệch byte ($t0)
    add  $t1, $s0, $t0          # $t1 = $s0 + $t0 = Địa chỉ con trỏ trỏ trực tiếp đến array[index]

    # --------------------------------------------------------------------------
    # BƯỚC 5: NẠP GIÁ TRỊ TỪ RAM VÀO CPU VÀ IN KẾT QUẢ RA MÀN HÌNH
    # Tương đương C : printf("%d\n", *ptr);
    # Tương đương C#: Console.WriteLine(array[index]);
    # --------------------------------------------------------------------------
    # Lệnh `lw` (Load Word) đọc đúng 4 bytes từ ô nhớ RAM tại địa chỉ $t1 nạp vào thanh ghi $a0
    lw   $a0, 0($t1)            # $a0 = giá trị của phần tử array[index] lưu trong RAM

    li   $v0, 1                 # Syscall 1: Dịch vụ in số nguyên ra màn hình console (print_int)
    syscall                     # In giá trị số nguyên trong $a0 ra màn hình

    # In ký tự xuống dòng để kết thúc giao diện hiển thị gọn gàng
    li   $v0, 4                 # Syscall 4: In chuỗi
    la   $a0, newline           # Nạp địa chỉ chuỗi "\n" vào $a0
    syscall

    # Thoát chương trình bình thường (Exit code 0)
    li   $v0, 10                # Syscall 10: Dịch vụ kết thúc chương trình an toàn
    syscall

# ------------------------------------------------------------------------------
# KHỐI XỬ LÝ NGOẠI LỆ (EXCEPTION HANDLER): Khi index < 0 hoặc index > 4
# ------------------------------------------------------------------------------
error_index:
    li   $v0, 4                 # Syscall 4: In chuỗi thông báo lỗi
    la   $a0, err_index         # In "Error: Index out of bounds (must be between 0 and 4)!\n"
    syscall

    li   $v0, 10                # Syscall 10: Thoát chương trình an toàn, không để code chạy bừa bãi
    syscall


# ==============================================================================
# PHẦN THAM KHẢO MỞ RỘNG: SỬ DỤNG VÒNG LẶP FOR VỚI CÁC LỆNH RẼ NHÁNH
# (Dành cho việc đối chiếu và mở rộng khi mảng có kích thước lớn N phần tử)
# ==============================================================================
#
# 1. NGUYÊN LÝ HOẠT ĐỘNG:
#    - Khi số lượng phần tử mảng tăng lên (ví dụ N = 10 hoặc N = 100 phần tử), phương án
#      trải mã tuần tự ở trên sẽ khiến mã nguồn phình to hàng trăm dòng lặp lại.
#    - Khi đó, dùng vòng lặp FOR với biến đếm i chạy từ 0 đến N - 1 là giải pháp tối ưu
#      về độ dài mã nguồn và tính bảo trì.
#
# 2. GIẢI THÍCH CHI TIẾT TỪNG LỆNH TRONG VÒNG LẶP FOR:
#    - `li $t0, 0`               : Khởi tạo biến đếm chỉ số logic i = 0.
#    - `li $t8, 5`               : Nạp số lượng phần tử N = 5 vào thanh ghi chặn biên $t8.
#    - `bge $t0, $t8, done_loop` : Branch if Greater than or Equal. So sánh i với 5.
#                                  Nếu i >= 5 (đã nhập đủ 5 phần tử từ 0 đến 4) thì thoát vòng lặp.
#    - `sll $t1, $t0, 2`         : Dịch trái logic 2 bit (Offset = i * 4) để quy đổi từ chỉ số
#                                  logic i sang độ lệch byte vật lý trên thanh RAM.
#    - `add $t2, $s0, $t1`       : Tính địa chỉ thực của ô nhớ RAM: Base + Offset = &array[i].
#    - `sw $v0, 0($t2)`          : Ghi 4 bytes từ $v0 vào ô nhớ RAM tại địa chỉ $t2.
#    - `addi $t0, $t0, 1`        : Tăng biến đếm logic i lên 1 (tương đương i++ trong C/C#).
#    - `j loop_input_ref`        : Lệnh nhảy vô điều kiện (Unconditional Jump), đưa con trỏ lệnh
#                                  quay ngược lại đầu vòng lặp để tiếp tục nhập phần tử kế tiếp.
#
# 3. ĐOẠN MÃ MIPS HOÀN CHỈNH CỦA PHƯƠNG ÁN VÒNG LẶP FOR:
# ------------------------------------------------------------------------------
# .data
#     p_elm:      .asciiz "Please input element "
#     colon:      .asciiz ": "
#     p_idx_loop: .asciiz "Please enter index: "
#     err_loop:   .asciiz "Error: Index out of bounds (must be between 0 and 4)!\n"
#     nl_loop:    .asciiz "\n"
#     .align 2
#     arr_loop:   .space 20
#
# .text
# main_for_loop:
#     la   $s0, arr_loop          # $s0 = Địa chỉ cơ sở của mảng trong RAM
#     li   $t0, 0                 # $t0 = i = 0 (Khởi tạo biến đếm chỉ số logic)
#     li   $t8, 5                 # $t8 = N = 5 (Số lượng phần tử cần lặp của mảng)
#
# loop_input_ref:
#     # Điều kiện dừng: if (i >= 5) break;
#     bge  $t0, $t8, done_loop    # Nếu biến đếm i >= 5 -> Đã nhập đủ, thoát vòng lặp
#
#     # In chuỗi câu nhắc động: "Please input element <i>: "
#     li   $v0, 4; la $a0, p_elm; syscall     # In "Please input element "
#     li   $v0, 1; move $a0, $t0; syscall     # In giá trị biến đếm i hiện tại
#     li   $v0, 4; la $a0, colon; syscall     # In dấu ": "
#
#     # Đọc số nguyên từ bàn phím: scanf("%d", &array[i])
#     li   $v0, 5; syscall                    # Người dùng nhập số nguyên, lưu vào $v0
#
#     # Quy đổi chỉ số logic sang địa chỉ byte RAM và lưu dữ liệu:
#     sll  $t1, $t0, 2            # $t1 = i * 4 (Độ lệch byte trong RAM)
#     add  $t2, $s0, $t1          # $t2 = Base + Offset (Địa chỉ ô nhớ thực của array[i])
#     sw   $v0, 0($t2)            # Ghi 4 bytes từ $v0 vào ô nhớ RAM $t2
#
#     # Tăng biến đếm và lặp lại:
#     addi $t0, $t0, 1            # i = i + 1 (i++)
#     j    loop_input_ref         # Nhảy quay lại đầu vòng lặp để xét phần tử tiếp theo
#
# done_loop:
#     # Nhập index tra cứu:
#     li   $v0, 4; la $a0, p_idx_loop; syscall
#     li   $v0, 5; syscall
#
#     # Bắt ngoại lệ ranh giới mảng [0, 4]:
#     bltz $v0, err_ref           # Nếu index < 0 -> Báo lỗi
#     li   $t9, 4
#     bgt  $v0, $t9, err_ref      # Nếu index > 4 -> Báo lỗi
#
#     # Truy xuất phần tử tức thì O(1) bằng số học con trỏ:
#     sll  $t0, $v0, 2            # Offset = index * 4
#     add  $t1, $s0, $t0          # Địa chỉ tuyệt đối = Base + Offset
#     lw   $a0, 0($t1)            # Nạp 4 bytes từ RAM vào $a0
#
#     # In kết quả và kết thúc:
#     li   $v0, 1; syscall        # In giá trị phần tử
#     li   $v0, 4; la $a0, nl_loop; syscall
#     li   $v0, 10; syscall       # Thoát an toàn
#
# err_ref:
#     li   $v0, 4; la $a0, err_loop; syscall
#     li   $v0, 10; syscall
#
# ------------------------------------------------------------------------------
# 4. SO SÁNH KHI KÍCH THƯỚC MẢNG TĂNG LÊN (VÍ DỤ 10 PHẦN TỬ):
# ------------------------------------------------------------------------------
#
# A) PHƯƠNG ÁN 1 (TRẢI MÃ TUẦN TỰ - MAIN IMPLEMENTATION):
#    - Cấp phát bộ nhớ: Sửa `.space 20` thành `.space 40` (10 phần tử * 4 bytes).
#    - Khai báo thêm chuỗi câu nhắc: Cần thêm 5 chuỗi từ `prompt5` đến `prompt9`.
#    - Mở rộng khối lệnh: Cần viết thêm 5 khối lệnh nạp/lưu với các offset 20, 24, 28, 32, 36.
#    - Kiểm tra ngoại lệ: Sửa cận trên từ 4 thành 9 (`li $t9, 9`).
#    - Logic truy xuất O(1): Giữ nguyên (`sll $t0, $v0, 2` + `add $t1, $s0, $t0` + `lw $a0, 0($t1)`).
#    => Đánh giá: Mã nguồn dài thêm khi số lượng phần tử tăng, thích hợp cho mảng nhỏ cố định.
#
# B) PHƯƠNG ÁN 2 (VÒNG LẶP FOR - MỞ RỘNG):
#    - Cấp phát bộ nhớ: Sửa `.space 20` thành `.space 40`.
#    - Câu nhắc hiển thị: Sử dụng biến đếm $t0 để in chỉ số động, không cần khai báo thêm chuỗi.
#    - Điều kiện dừng: Sửa điều kiện lặp từ 5 thành 10 (`li $t8, 10`).
#    - Kiểm tra ngoại lệ: Sửa cận trên từ 4 thành 9 (`li $t9, 9`).
#    - Thân vòng lặp: Giữ nguyên, không phải viết thêm lệnh.
#    => Đánh giá: Cấu trúc ngắn gọn, dễ mở rộng quy mô khi làm việc với mảng kích thước lớn.
# ==============================================================================
