using System.Collections.Generic;

namespace lucy_auth_payment.Modules.Payment.Services
{
    public class MockBankService : IMockBankService
    {
        private readonly Dictionary<string, string> _mockAccounts = new()
        {
            // Các ngân hàng lớn phổ biến
            { "VCB_123456789", "NGUYEN VAN A" },           // Vietcombank
            { "VCB_098765432", "TRAN THI B" },             // Vietcombank
            { "MB_987654321", "LE VAN C" },                // MBBank
            { "MB_112233445", "PHAN THI D" },              // MBBank
            { "TCB_190312345", "HOANG VAN E" },            // Techcombank
            { "TCB_190354321", "NGO THI F" },              // Techcombank
            { "BIDV_120100012", "DANG VAN G" },            // BIDV
            { "CTG_101010101", "BUI THI H" },              // VietinBank
            { "ACB_223344556", "DOAN VAN I" },             // ACB
            { "VPB_667788990", "LY THI K" },               // VPBank
            
            // Tài khoản đặc biệt để test lỗi (VD: Bị khóa)
            { "TCB_000000000", "TAI KHOAN BI KHOA" } 
        };

        public string? LookupAccountName(string bankCode, string accountNumber)
        {
            string key = $"{bankCode}_{accountNumber}";
            if (_mockAccounts.TryGetValue(key, out string? accountName))
            {
                return accountName;
            }
            return null;
        }
    }
}
