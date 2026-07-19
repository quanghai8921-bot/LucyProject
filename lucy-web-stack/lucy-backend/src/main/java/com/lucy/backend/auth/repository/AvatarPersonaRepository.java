package com.lucy.backend.auth.repository;

import com.lucy.backend.auth.entity.AvatarPersona;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AvatarPersonaRepository extends JpaRepository<AvatarPersona, String> {
}
