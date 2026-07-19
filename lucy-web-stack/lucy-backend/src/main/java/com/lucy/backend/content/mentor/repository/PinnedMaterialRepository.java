package com.lucy.backend.content.mentor.repository;

import com.lucy.backend.content.mentor.entity.PinnedMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PinnedMaterialRepository extends JpaRepository<PinnedMaterial, String> {
    List<PinnedMaterial> findByRoomIdOrderByDisplayOrderAsc(String roomId);
    void deleteByRoomId(String roomId);
}
