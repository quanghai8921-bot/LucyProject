package com.lucy.backend.payment.repository;

import com.lucy.backend.payment.entity.LiveAccessTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface LiveAccessTicketRepository extends JpaRepository<LiveAccessTicket, String> {
    List<LiveAccessTicket> findByUserId(String userId);
    List<LiveAccessTicket> findByUserIdAndTicketStatus(String userId, String ticketStatus);
}
