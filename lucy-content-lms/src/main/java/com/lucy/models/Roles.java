package com.lucy.models;

public class Roles {
    private String RoleId;
    private String RoleName;
    private String Description;

    public Roles() {
    }

    public Roles(String RoleId, String RoleName, String Description) {
        this.RoleId = RoleId;
        this.RoleName = RoleName;
        this.Description = Description;
    }

    public String getRoleId() {
        return this.RoleId;
    }

    public void setRoleId(String RoleId) {
        this.RoleId = RoleId;
    }

    public String getRoleName() {
        return this.RoleName;
    }

    public void setRoleName(String RoleName) {
        this.RoleName = RoleName;
    }

    public String getDescription() {
        return this.Description;
    }

    public void setDescription(String Description) {
        this.Description = Description;
    }
}