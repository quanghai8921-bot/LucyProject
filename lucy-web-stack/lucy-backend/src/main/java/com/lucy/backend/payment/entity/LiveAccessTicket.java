package com.lucy.backend.payment.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "LiveAccessTickets")
@Data
public class LiveAccessTicket {
    @Id
    @Column(name = "TicketId", length = 50)
    private String ticketId;

    @Column(name = "RoomId", length = 50)
    private String roomId;

    @Column(name = "UserId", length = 50, nullable = false)
    private String userId;

    @Column(name = "WalletId", length = 50)
    private String walletId;

    @Column(name = "TicketStatus", length = 30, nullable = false)
    private String ticketStatus = "ACTIVE";
}
