package com.lucy.models;

public class Users {
    private String UserId;
    private String FullName;
    private String PhoneNumber;
    private String Email;
    private String Passwords;
    private int IsStatus;
    private String RoleId;

    public Users() {
    }

    public Users(String UserId, String FullName, String PhoneNumber, String Email, String Passwords, int IsStatus,
            String RoleId) {
        this.UserId = UserId;
        this.FullName = FullName;
        this.PhoneNumber = PhoneNumber;
        this.Email = Email;
        this.Passwords = Passwords;
        this.IsStatus = IsStatus;
        this.RoleId = RoleId;
    }

    public String getUserId() {
        return this.UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public String getFullName() {
        return this.FullName;
    }

    public void setFullName(String FullName) {
        this.FullName = FullName;
    }

    public String getPhoneNumber() {
        return this.PhoneNumber;
    }

    public void setPhoneNumber(String PhoneNumber) {
        this.PhoneNumber = PhoneNumber;
    }

    public String getEmail() {
        return this.Email;
    }

    public void setEmail(String Email) {
        this.Email = Email;
    }

    public String getPasswords() {
        return this.Passwords;
    }

    public void setPasswords(String Passwords) {
        this.Passwords = Passwords;
    }

    public int getIsStatus() {
        return this.IsStatus;
    }

    public void setIsStatus(int IsStatus) {
        this.IsStatus = IsStatus;
    }

    public String getRoleId() {
        return this.RoleId;
    }

    public void setRoleId(String RoleId) {
        this.RoleId = RoleId;
    }
}